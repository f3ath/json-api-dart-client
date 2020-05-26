import 'dart:convert';

import 'package:json_api/json_api.dart';
import 'package:json_api_common/http.dart';

final fetchCollection200 = HttpResponse(200,
    headers: {'Content-Type': ContentType.jsonApi},
    body: jsonEncode({
      'links': {
        'self': 'http://example.com/articles',
        'next': 'http://example.com/articles?page[offset]=2',
        'last': 'http://example.com/articles?page[offset]=10'
      },
      'data': [
        {
          'type': 'articles',
          'id': '1',
          'attributes': {'title': 'JSON:API paints my bikeshed!'},
          'relationships': {
            'author': {
              'links': {
                'self': 'http://example.com/articles/1/relationships/author',
                'related': 'http://example.com/articles/1/author'
              },
              'data': {'type': 'people', 'id': '9'}
            },
            'comments': {
              'links': {
                'self': 'http://example.com/articles/1/relationships/comments',
                'related': 'http://example.com/articles/1/comments'
              },
              'data': [
                {'type': 'comments', 'id': '5'},
                {'type': 'comments', 'id': '12'}
              ]
            }
          },
          'links': {'self': 'http://example.com/articles/1'}
        }
      ],
      'included': [
        {
          'type': 'people',
          'id': '9',
          'attributes': {
            'firstName': 'Dan',
            'lastName': 'Gebhardt',
            'twitter': 'dgeb'
          },
          'links': {'self': 'http://example.com/people/9'}
        },
        {
          'type': 'comments',
          'id': '5',
          'attributes': {'body': 'First!'},
          'relationships': {
            'author': {
              'data': {'type': 'people', 'id': '2'}
            }
          },
          'links': {'self': 'http://example.com/comments/5'}
        },
        {
          'type': 'comments',
          'id': '12',
          'attributes': {'body': 'I like XML better'},
          'relationships': {
            'author': {
              'data': {'type': 'people', 'id': '9'}
            }
          },
          'links': {'self': 'http://example.com/comments/12'}
        }
      ]
    }));

final fetchResource200 = HttpResponse(200,
    headers: {'Content-Type': ContentType.jsonApi},
    body: jsonEncode({
      'links': {'self': 'http://example.com/articles/1'},
      'data': {
        'type': 'articles',
        'id': '1',
        'attributes': {'title': 'JSON:API paints my bikeshed!'},
        'relationships': {
          'author': {
            'links': {'related': 'http://example.com/articles/1/author'}
          }
        }
      }
    }));
final fetchRelatedResourceNull200 = HttpResponse(200,
    headers: {'Content-Type': ContentType.jsonApi},
    body: jsonEncode({
      'links': {'self': 'http://example.com/articles/1/author'},
      'data': null
    }));
final error422 = HttpResponse(422,
    headers: {'Content-Type': ContentType.jsonApi},
    body: jsonEncode({
      'errors': [
        {
          'status': '422',
          'source': {'pointer': '/data/attributes/firstName'},
          'title': 'Invalid Attribute',
          'detail': 'First name must contain at least three characters.'
        }
      ]
    }));
