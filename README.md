##  API Call Patterns

ref: https://medium.com/@isikakin95/simpleapp-krakend-api-gateway-templates-part-ii-187685599079
### Create Account
Call Sequence:
1) Client hit the api gateway with payload
2) Api-Gateway hits the `/api/v1/user` endpoint on the user service with the below payload to create a user record.
    A) User service processes and performs sanitation checks on the request object, calls the `import account` endpoint of the authentication service (with email and password fields)
       If successful, it obtains an `authnId` which is the ID of the auth record stored in the auth svc tied to the user acct of interest, updates the user record (with authnID) and saves it locally in its db. It returns to the client the ID of the newly created user record
Client will be returned the ID of the newly create user object. 


Client should then invoke `/v1/gateway/user/setup/{userId}` on the gateway
Gateway with the ID of the created user record, calls `/api/v1/token/setup/{userId}` endpoint of the financial integration service to initiate link token account creation. The result of this call is a link token which is returned to the gateway, then subsequently to the client to initiate the token exchange from the frontend

-- Client must go through the plaid onboarding process. This is commenced by passing the link token from backend to frontend. User will then be placed in a `link flow`
When user completes the Link flow, Link will pass back a `public_token` via the onSuccess callback. This will be used to call the `create account with token exchange` api call.

__Gateway Endpoint__
```bash
Verb: POST
Endpoint: /v1/gateway/user
BODY: *
```
__Input: Client Payload__
```bash
{
  "account": {
    "email": "test@gmail.com",
    "address": {
      "Address": "340 Clifton Pl",
      "Unit": "3B",
      "ZipCode": "11216",
      "City": "Brooklyn",
      "State": "NY",
      "longitude": "N 1123.4",
      "lattitude": "113.123.4"
    },
    "bio": "setup new account",
    "headline": "setup new account object",
    "phoneNumber": "001110110",
    "tags": [
      {
        "tagName": "sample tag",
        "tagDescription": "string",
        "metadata": [
          "string"
        ]
      }
    ],
    "firstname": "test",
    "lastname": "user",
    "username": "testuser1",
    "password": "testest"
  }
}
```

__Output: Response Payload__
```bash
{
  "userID": "string"
}
```

__Gateway Endpoint__
```bash
Verb: POST
Endpoint: /v1/gateway/user/setup/{userId}
```

__Output: Response Payload__
```bash
{
  "linkToken": "string",
  "expiration": "string"
  "plaidRequestID": "string"
}
```

### Create Account With Token Exchange
Call Sequence:
Client calls the `/v1/gateway/user/token-exchange/{userID}/{publicToken}` endpoint on the gateway. Gateway forwards the request to the `/api/v1/token/exchange/{userID}/{publicToken}` of the financial integration service. The financial integration service calls the plaid api pulling the financial records of the individual, creating a vritual account and trying the financial records together then storing locally in the database. Once stored, the ID of the created virtual account record will be returned

__Gateway Endpoint__
```bash
Verb: POST
Endpoint: /v1/gateway/user/token-exchange/{userID}/{publicToken}
```
__Input: Client Payload__
```bash
  No Payload In Request Body
```

__Output: Response Payload__
```bash
{
    "virtualAccountID": "string"
}
```

### Logout User
Call Sequence
Client calls `/v1/gateway/user/logout/{id}` endpoint on the gateway which calls the `/api/v1/user/logout/{id}` endpoint on the headless authentication service.
Up success response, gateway returns success to client. Client should then wipe the JWT token from the client cache so as to not pass it in subsequent requests.

__Gateway Endpoint__
```bash
Verb: Post
Endpoint: /v1/gateway/user/logout/{userID}
```

__Input: Client Payload__
```bash
   No Payload In Request Body
```

__Output: Response Payload__
```bash
{
    "code": "string",
    "error": "string"
}
```

JWT Token needs to be present

### Delete User
Call Sequence
Client call `/v1/gateway/user/{id}` endpoint on the gateway which calls the `/api/v1/user/{id}` endpoint on the user service with the delete verb. The user service then performs a set of operations as a dtx. It invokes the auth svcs and locks the user record from the context of that service, then locks the account record from the context of the financial integration service and then locks the records in the user service table. All subtransactions of the deletion dtx are atomic. So if one sub-tx fails, all prior tx roll back.

NOTE: locking in this context is a form of soft deletion

__Gateway Endpoint__
```bash
Verb: DELETE
Endpoint: /v1/gateway/user/{userID}
```

__Input: Client Payload__
```bash
    No Payload In Request Body
```

__Output: Response Payload__
```bash
    {
        "AccountDeleted": true
    }
```

JWT Token needs to be present

### Authenticating User
Call Sequence
- login user in headless auth svc and get JWT Token From Auth Svc
- call user svc with the provided email and obtain the user ID
    // NEED API ENDPOINT TO EXCHANGE EMAIL FOR ID
- call the financial integration service with the user ID and obtain the virtual account and return to client

__Gateway Endpoint__
```bash
Verb: POST
Endpoint: /v1/gateway/user/login/{email}/{password}
```
__Input: Client Payload__
```bash
   No Payload In Request Body
```

__Output: Response Payload__
```bash
{
  "JWT": "string",
  "UserID": "string"
  "VirtualAccountID": "string"
}

```