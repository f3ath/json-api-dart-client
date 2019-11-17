[JSON:API](http://jsonapi.org) is a specification for building APIs in JSON. 

# Client
Quick usage example:
```dart
import 'package:http/http.dart';
import 'package:json_api/json_api.dart';

void main() async {
  final httpClient = Client();
  final jsonApiClient = JsonApiClient(httpClient);
  final companiesUri = Uri.parse('http://localhost:8080/companies');
  final response = await jsonApiClient.fetchCollection(companiesUri);
  httpClient.close();
  print('Status: ${response.status}');
  print('Headers: ${response.headers}');

  final resource = response.data.unwrap().first;

  print('The collection page size is ${response.data.collection.length}');
  print('The first element is ${resource}');
  print('Attributes:');
  resource.attributes.forEach((k, v) => print('$k=$v'));
  print('Relationships:');
  resource.toOne.forEach((k, v) => print('$k=$v'));
  resource.toMany.forEach((k, v) => print('$k=$v'));
}
```
To see this in action:
 
 1. start the server:
```
$ dart example/cars_server.dart
Listening on 127.0.0.1:8080
```
2. run the script:
```
$ dart example/fetch_collection.dart 
Status: 200
Headers: {x-frame-options: SAMEORIGIN, content-type: application/vnd.api+json, x-xss-protection: 1; mode=block, x-content-type-options: nosniff, transfer-encoding: chunked, access-control-allow-origin: *}
The collection page size is 1
The first element is Resource(companies:1)
Attributes:
name=Tesla
nasdaq=null
updatedAt=2019-07-07T13:08:18.125737
Relationships:
hq=Identifier(cities:2)
models=[Identifier(models:1), Identifier(models:2), Identifier(models:3), Identifier(models:4)]
```

The client provides a set of methods to deal with resources and relationships.
- Fetching
    - [fetchCollection](https://pub.dev/documentation/json_api/latest/client/JsonApiClient/fetchCollection.html) - resource collection, either primary or related
    - [fetchResource](https://pub.dev/documentation/json_api/latest/client/JsonApiClient/fetchResource.html) - a single resource, either primary or related
    - [fetchRelationship](https://pub.dev/documentation/json_api/latest/client/JsonApiClient/fetchRelationship.html) - a generic relationship (either to-one, to-many or even incomplete)
    - [fetchToOne](https://pub.dev/documentation/json_api/latest/client/JsonApiClient/fetchToOne.html) - a to-one relationship
    - [fetchToMany](https://pub.dev/documentation/json_api/latest/client/JsonApiClient/fetchToMany.html) - a to-many relationship
- Manipulating resources
    - [createResource](https://pub.dev/documentation/json_api/latest/client/JsonApiClient/createResource.html) - creates a new primary resource
    - [updateResource](https://pub.dev/documentation/json_api/latest/client/JsonApiClient/updateResource.html) - updates the existing resource by its type and id
    - [deleteResource](https://pub.dev/documentation/json_api/latest/client/JsonApiClient/deleteResource.html) - deletes the existing resource
- Manipulating relationships
    - [replaceToOne](https://pub.dev/documentation/json_api/latest/client/JsonApiClient/replaceToOne.html) - replaces the existing to-one relationship with a new resource identifier
    - [deleteToOne](https://pub.dev/documentation/json_api/latest/client/JsonApiClient/deleteToOne.html) - deletes the existing to-one relationship by setting the resource identifier to null
    - [replaceToMany](https://pub.dev/documentation/json_api/latest/client/JsonApiClient/replaceToMany.html) - replaces the existing to-many relationship with the given set of resource identifiers
    - [addToMany](https://pub.dev/documentation/json_api/latest/client/JsonApiClient/addToMany.html) - adds the given identifiers to the existing to-many relationship
    
These methods accept the target URI and the object to update (except for fetch and delete requests).
You can also pass an optional map of HTTP headers, e.g. for authentication. The return value
is a [Response] object. 

You can get the status of the [Response] from either [Response.status] or one of the following properties: 
- [Response.isSuccessful]
- [Response.isFailed]
- [Response.isAsync] (see [Asynchronous Processing])

The Response also contains the raw [Response.status] and a map of HTTP headers.
Two headers used by JSON:API can be accessed directly for your convenience:
- [Response.location] holds the `Location` header used in creation requests
- [Response.contentLocation] holds the `Content-Location` header used for [Asynchronous Processing]

The most important part of the Response is the [Response.document] containing the JSON:API document sent by the server (if any). 
If the document has the Primary Data, you can use [Response.data] shortcut to access it directly.

#### Included resources
If you requested related resources to be included in the response (see [Compound Documents]) and the server fulfilled
your request, the [PrimaryData.included] property will contain them.

#### Errors
For unsuccessful operations the [Response.data] property will be null. 
If the server decided to include the error details in the response, those can be found in the  [Document.errors] property.

#### Async processing
Some servers may support [Asynchronous Processing].
When the server responds with `202 Accepted`, the client expects the Primary Data to always be a Resource (usually
representing a job queue). In this case, [Response.document] and [Response.data] will be null. Instead, 
the response document will be placed to [Response.asyncDocument] (and [Response.asyncData]). 
Also in this case the [Response.contentLocation]
will point to the job queue resource. You can fetch the job queue resource periodically and check
the type of the returned resource. Once the operation is complete, the request will return the created resource.

#### Adding JSON:API Object
It is possible to add the [JSON:API Object] to all documents sent by the [JsonApiClient]. To do so, pass the
pre-configured [DocumentBuilder] to the [JsonApiClient]:
```dart
import 'package:http/http.dart';
import 'package:json_api/json_api.dart';

void main() async {
  final api = Api(version: "1.0");
  final httpClient = Client();
  final jsonApiClient = JsonApiClient(httpClient, builder: DocumentBuilder(api: api));
}

```


# Server
The server included in this package is still under development. It is not yet suitable for real production environment
except maybe for really simple demo or testing cases.

## URL Design
The URL Design specifies the structure of the URLs used for specific targets. The JSON:API standard describes 4
possible request targets:
- Collections (parameterized by the resource type)
- Individual resources (parameterized by the resource type and id)
- Related resources and collections (parameterized by the resource type, resource id and the relation name)
- Relationships (parameterized by the resource type, resource id and the relation name)

The [UrlBuilder] builds those 4 kinds of URLs by the given parameters. The [TargetMatcher] does the opposite,
it determines the target of the given URL (if possible). Together they form the [UrlDesign].

This package provides one built-in implementation of [UrlDesign] which is called [PathBasedUrlDesign].
The [PathBasedUrlDesign] implements the [Recommended URL Design] allowing you to specify the a common prefix
for all your JSON:API endpoints.


[Document.errors]: https://pub.dev/documentation/json_api/latest/document/Document/errors.html
[DocumentBuilder]: 
[JsonApiClient]: https://pub.dev/documentation/json_api/latest/client/JsonApiClient-class.html
[PathBasedUrlDesign]: https://pub.dev/documentation/json_api/latest/url_design/PathBasedUrlDesign-class.html
[PrimaryData.included]: https://pub.dev/documentation/json_api/latest/document/PrimaryData/included.html
[Response]: https://pub.dev/documentation/json_api/latest/client/Response-class.html
[Response.data]: https://pub.dev/documentation/json_api/latest/client/Response/data.html
[Response.document]: https://pub.dev/documentation/json_api/latest/client/Response/document.html
[Response.isSuccessful]: https://pub.dev/documentation/json_api/latest/client/Response/isSuccessful.html
[Response.isFailed]: https://pub.dev/documentation/json_api/latest/client/Response/isFailed.html
[Response.isAsync]: https://pub.dev/documentation/json_api/latest/client/Response/isAsync.html
[Response.location]: https://pub.dev/documentation/json_api/latest/client/Response/location.html
[Response.contentLocation]: https://pub.dev/documentation/json_api/latest/client/Response/contentLocation.html
[Response.status]: https://pub.dev/documentation/json_api/latest/client/Response/status.html
[Response.asyncDocument]: https://pub.dev/documentation/json_api/latest/client/Response/asyncDocument.html
[Response.asyncData]: https://pub.dev/documentation/json_api/latest/client/Response/asyncData.html
[TargetMatcher]: https://pub.dev/documentation/json_api/latest/url_design/TargetMatcher-class.html
[UrlBuilder]: https://pub.dev/documentation/json_api/latest/url_design/UrlBuilder-class.html
[UrlDesign]: https://pub.dev/documentation/json_api/latest/url_design/UrlDesign-class.html

[Asynchronous Processing]: https://jsonapi.org/recommendations/#asynchronous-processing
[Compound Documents]: https://jsonapi.org/format/#document-compound-documents
[JSON:API Object]: https://jsonapi.org/format/#document-jsonapi-object
[Recommended URL Design]: https://jsonapi.org/recommendations/#urls