/**
 * Copyright IBM Corporation 2016
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import Foundation
import RestKit

/**
 The IBM Watson Discovery service uses data analysis combined with cognitive intuition to take your
 unstructured data and enrich it so you can query it for the information you need.
 */
public class Discovery {

    /// The base URL to use when contacting the service.
    public var serviceURL = "https://gateway.watsonplatform.net/discovery-experimental/api"
    
    /// The default HTTP headers for all requests to the service.
    public var defaultHeaders = [String: String]()
    
    private let credentials: Credentials
    private let domain = "com.ibm.watson.developer-cloud.DiscoveryV1"
    private let version: String
    
    /**
     Create a `Discovery` object.
     
     - parameter username: The username used to authenticate with the service.
     - parameter password: The password used to authenticate with the service.
     - parameter version: The release date of the version of the API to use. Specify the date
            in "YYYY-MM-DD" format.
     */
    public init(username: String, password: String, version: String) {
        self.credentials = Credentials.basicAuthentication(username: username, password: password)
        self.version = version
    }
    
    /**
     If the given data represents an error returned by the Discovery service, then return
     an NSError with information about the error that occured. Otherwise, return nil.
     
     - parameter data: Raw data returned from the service that may represent an error.
     */
    private func dataToError(data: Data) -> NSError? {
        do {
            let json = try JSON(data: data)
            let error = try json.getString(at: "error")
            let code = try json.getInt(at: "code")
            let userInfo = [NSLocalizedFailureReasonErrorKey: error]
            return NSError(domain: domain, code: code, userInfo: userInfo)
        } catch {
            return nil
        }
    }
    
    // MARK: - Environments
    
    /**
     Get all existing environments for this Discovery instance.
     
     - parameter name: Show only the environment with the given name.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with a list of all environments associated with this service instance.
     */
    public func getEnvironments (
        withName name: String? = nil,
        failure: ((Error) -> Void)? = nil,
        success: @escaping ([Environment]) -> Void)
    {
        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))
        if let name = name {
            queryParameters.append(URLQueryItem(name: "name", value: name))
        }
        
        // construct REST request
        let request = RestRequest(
            method: "GET",
            url: serviceURL + "/v1/environments",
            credentials: credentials,
            headerParameters: defaultHeaders,
            acceptType: "application/json",
            queryItems: queryParameters
        )
        
        // execute REST request
        request.responseArray(dataToError: dataToError, path: ["environments"]) {
            (response: RestResponse<[Environment]>) in
            switch response.result {
            case .success(let environments): success(environments)
            case .failure(let error): failure?(error)
            }
        }
    }
    
    /**
     Create an environment for this service instance.
     
     For the experimental release, the size of the environment is fixed at 2GB
     available disk space, and 1GB RAM.
     
     - parameter name: The name of the new environment.
     - parameter description: The description of the new environment.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with details of the newly created environment.
     */
    public func createEnvironment(
        withName name: String,
        withDescription description: String? = nil,
        failure: ((Error) -> Void)? = nil,
        success: @escaping (Environment) -> Void)
    {
        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))
        
        // construct body
        var jsonData = [String: Any]()
        jsonData["name"] = name
        if let description = description {
            jsonData["description"] = description
        }
        guard let body = try? JSON(dictionary: jsonData).serialize() else {
            failure?(RestError.encodingError)
            return
        }
        
        // construct REST request
        let request = RestRequest(
            method: "POST",
            url: serviceURL + "/v1/environments",
            credentials: credentials,
            headerParameters: defaultHeaders,
            acceptType: "application/json",
            contentType: "application/json",
            queryItems: queryParameters,
            messageBody: body
        )
        
        // execute REST request
        request.responseObject(dataToError: dataToError) {
            (response: RestResponse<Environment>) in
            switch response.result {
            case .success(let environment): success(environment)
            case .failure(let error): failure?(error)
            }
        }
    }
    
    /**
     Delete the environment with the given environment ID.
     
     - parameter environmentID: The name of the new environment.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with details of the newly deleted environment.
     */
    public func deleteEnvironment(
        withID environmentID: String,
        failure: ((Error) -> Void)? = nil,
        success: @escaping (DeletedEnvironment) -> Void)
    {
        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))
        
        // construct REST request
        let request = RestRequest(
            method: "DELETE",
            url: serviceURL + "/v1/environments/\(environmentID)",
            credentials: credentials,
            headerParameters: defaultHeaders,
            queryItems: queryParameters
        )
        
        // execute REST request
        request.responseObject(dataToError: dataToError) {
            (response: RestResponse<DeletedEnvironment>) in
            switch response.result {
            case .success(let environment): success(environment)
            case .failure(let error): failure?(error)
            }
        }
    }
    
    /**
     Retrieve information about an environment.
     
     - parameter environmentID: The ID of the environment to retrieve information about.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with information about the requested environment.
     */
    public func getEnvironment(
        withID environmentID: String,
        failure: ((Error) -> Void)? = nil,
        success: @escaping (Environment) -> Void)
    {
        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))
        
        // construct REST request
        let request = RestRequest(
            method: "GET",
            url: serviceURL + "/v1/environments/\(environmentID)",
            credentials: credentials,
            headerParameters: defaultHeaders,
            queryItems: queryParameters
        )
        
        // execute REST request
        request.responseObject(dataToError: dataToError) {
            (response: RestResponse<Environment>) in
            switch response.result {
            case .success(let environment): success(environment)
            case .failure(let error): failure?(error)
            }
        }
    }
    
    /**
     Update an environment.
     
     - parameter environmentID: The ID of the environment to retrieve information about.
     - parameter name: The updated name of the environment.
     - parameter description: The updated description of the environment.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with information about the requested environment.
     */
    public func updateEnvironment(
        withID environmentID: String,
        name: String? = nil,
        description: String? = nil,
        failure: ((Error) -> Void)? = nil,
        success: @escaping (Environment) -> Void)
    {
        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))
        
        // construct body
        var jsonData = [String: Any]()
        if let name = name {
            jsonData["name"] = name
        }
        if let description = description {
            jsonData["description"] = description
        }
        guard let body = try? JSON(dictionary: jsonData).serialize() else {
            failure?(RestError.encodingError)
            return
        }
        
        // construct REST request
        let request = RestRequest(
            method: "POST",
            url: serviceURL + "/v1/environments/\(environmentID)",
            credentials: credentials,
            headerParameters: defaultHeaders,
            acceptType: "application/json",
            contentType: "application/json",
            queryItems: queryParameters,
            messageBody: body
        )
        
        // execute REST request
        request.responseObject(dataToError: dataToError) {
            (response: RestResponse<Environment>) in
            switch response.result {
            case .success(let environment): success(environment)
            case .failure(let error): failure?(error)
            }
        }
    }
    
    // MARK: - Configurations

    /**
     List existing configurations for the service instance. 
    
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with details of the configurations.
    */
    public func getConfigurations(
        withEnvironmentID environmentID: String,
        withName name: String?,
        failure: ((Error) -> Void)? = nil,
        success: @escaping([Configuration]) -> Void)
    {
        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))
        
        // construct REST request
        let request = RestRequest(
            method: "GET",
            url: serviceURL + "/v1/environments/\(environmentID)/configurations",
            credentials: credentials,
            headerParameters: defaultHeaders,
            acceptType: "application/json",
            queryItems: queryParameters
        )
        
        // execute REST request
        request.responseArray(dataToError: dataToError, path: ["configurations"]) {
            (response: RestResponse<[Configuration]>) in
            switch response.result {
            case .success(let configurations): success(configurations)
            case .failure(let error): failure?(error)
            }
        }
    }

    // MARK: - Collections
    
    /**
     Get all existing collections.

     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with details of the collections.
    */
    public func getCollections(
        withEnvironmentID environmentID: String,
        failure: ((Error) -> Void)? = nil,
        success: @escaping([Collection]) -> Void)
    {
        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))
        
        // construct REST request
        let request = RestRequest(
            method: "GET",
            url: serviceURL + "/v1/environments/\(environmentID)/collections",
            credentials: credentials,
            headerParameters: defaultHeaders,
            acceptType: "application/json",
            queryItems: queryParameters
        )
        
        // execute REST request
        request.responseArray(dataToError: dataToError, path: ["collections"]) {
            (response: RestResponse<[Collection]>) in
            switch response.result {
            case .success(let collections): success(collections)
            case .failure(let error): failure?(error)
            }
        }
    }
    
    /**
     Create a new collection for storing documents.
     
     - parameter withEnvironmentID: The unique ID of the environment to create a collection in.
     - parameter withName: The name of the new collection.
     - parameter withDescription: The description of the configuration.
     - parameter withConfigurationID: The unique ID of the configuration the collection will be
        created with. To specify the default, call the getConfigurationID method.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with details of the created collection.
     */
    public func createCollection(
        withEnvironmentID environmentID: String,
        withName name: String,
        withDescription description: String?,
        withConfigurationID configurationID: String?,
        failure: ((Error) -> Void)? = nil,
        success: @escaping(Collection) -> Void)
    {
        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))
        
        // construct json from parameters
        var bodyData = [String: Any]()
        bodyData["name"] = name
        if let description = description {
            bodyData["description"] = description
        }
        if let configurationID = configurationID {
            bodyData["configuration_id"] = configurationID
        }
        guard let json = try? JSON(dictionary: bodyData).serialize() else {
            failure?(RestError.encodingError)
            return
        }
        
        // construct REST request
        let request = RestRequest(
            method: "POST",
            url: serviceURL + "/v1/environments/\(environmentID)/collections",
            credentials: .apiKey,
            headerParameters: defaultHeaders,
            acceptType: "application/json",
            contentType: "application/json",
            queryItems: queryParameters,
            messageBody: json
        )
        
        // execute REST request
        request.responseObject(dataToError: dataToError) {
            (response: RestResponse<Collection>) in
            switch response.result {
            case .success(let collection): success(collection)
            case .failure(let error): failure?(error)
            }
        }
    }
    
    /** Get collection details.*/
    
    /** Delete a collection in the environment the collection is located in.
     
     - parameter withEnvironmentID: The ID of the environment the collection is in.
     - parameter withCollectionID: The ID of the collection to delete.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with details of the newly deleted environment.
     */
    public func deleteCollection(
        withEnvironmentID environmentID: String,
        withCollectionID collectionID: String,
        failure: ((Error) -> Void)? = nil,
        success: @escaping (DeletedCollection) -> Void)
    {
        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))
        
        // construct REST request
        let request = RestRequest(
            method: "DELETE",
            url: serviceURL + "/v1/environments/\(environmentID)/collections/\(collectionID)",
            credentials: credentials,
            headerParameters: defaultHeaders,
            queryItems: queryParameters
        )
        
        // execute REST request
        request.responseObject(dataToError: dataToError) {
            (response: RestResponse<DeletedCollection>) in
            switch response.result {
            case .success(let collection): success(collection)
            case .failure(let error): failure?(error)
            }
        }
    }
 
}
