# Swift iOS Object Storage Sample for Bluemix Mobile Services Part 2
---
This project is a sample photo sharing application which fetches images from an Object Storage container and displays them to a user. The application is a tabbed view displaying photos from two containers--a public container which anyone can access, and a private container mapped to a logged in user. The user can upload a photo from either the photo library or the camera directly to Object Storage.

This project contains:

1. A node backend application which utilizes the `bluemix-objectstorage` node sdk
2. A simple custom identity provider to be used in conjunction with the Mobile Client Access service on Bluemix in order to protect resources on the node backend
3. A sample iOS application that make REST calls to the node backend to fetch, store, and load data from an Object Storage service instance on Bluemix

### Before you begin
Before you begin, ensure you have a [Bluemix](http://bluemix.net) account.

### Download this Sample
Clone the sample from GitHub using the following command:

`git clone https://github.com/ibm-bluemix-mobile-services/bluemix-object-storage-sample2.git`

### Create Object Storage instance
Object Storage credentials are used by the backend application. Before setting up the backend an instance of the Object Storage service will need to be created.

### Configure the custom identity provider
Before running the sample iOS application, an instance of the Mobile Client Access service will need to be created along with an instance of the Object Storage service. This identity provider will need to be configured in order to work with the Object Storage instance you created in the previous step.

Open `custom-identity-provider/app.js`. Edit the user repository object, which contains the iOS application's users' username, password, and additional optional information. At a minimum, replace `<user>` and `<password>` with a username & password combination of your choosing. You may supply additional users to the user repository object.

Deploy the custom identity provider to bluemix

1. Navigate to the `custom-identity-provider` directory
2. Open `manifest.yml` and edit any of the deployment parameters you wish to change
3. Run `cf push` using the cloud foundry cli

### Set-up Mobile Client Access
After successfully deploying the custom identity provider, an instance of Mobile Client Access will need to be created and bound to the identity provider.
Create an instance of Mobile Client Access:

1. From the Mobile section of the Bluemix Catalog, create an instance of the Mobile Client Access service
2. Bind the service instance to the custom identity provider just deployed
3. Setup the custom identity provider with Mobile Client Access

## Configuring Mobile Client Access service

1. To configure your Mobile Client Access service to use a newly deployed Custom Identity Provider. Open the Mobile Client Access Dashboard and enable Custom Authentication.
2. Use any alphanumerical string as `Realm name`. Keep a note of `Realm name`, you will need it to configure authentication in the Mobile Client Access SDK later.
3. Use the URL of the previously deployed Custom Identity Provider as `URL`

	> For more details about configuring Mobile Client Access service and mobile apps to use Custom Identity Providers and read [this documentation article. ](https://console.ng.bluemix.net/docs/services/mobileaccess/custom-auth-config-mca.html)

## Deploy the sample nodejs backend

1. Navigate to the `node-backend` directory
2. Open `manifest.yml` and edit any of the deployment parameters you wish to change
3. Replace `<object-storage>` and `<mca>` with the names of your Object Storage instance and Mobile Client Access instance, respectively
3. Run `cf push` using the cloud foundry cli

### Configure the sample iOS application
Build the project and necessary dependencies using either Cocoapods. Run `pod install` and open the `.xcworkspace` that is generated.

Edit the following line in `TabBarController.swift` with the appropriate app GUID, region, and URL:

```swift
BMSClient.sharedInstance.initializeWithBluemixAppRoute("<application-url>", bluemixAppGUID: "<appGuid>", bluemixRegion: "<region>")
```

Edit the following line in `TabBarController.swift` to match the realm name used when the custom identity provider was setup with Mobile Client Access:

```swift
let authenticationRealm = "<realmName>"
```

Edit the follwoing line in `PhotoContainer.swift` by replacing `<backend-url>` with the url mapped to the node backend:

```swift
var resourceUrl = "<backend-url>"
```

### Running the sample nodejs backend

The sample nodejs backend exposes four endpoints, `/public`, `/public/:objectName`, `/private` and `/private/:objectName`. The `/public` endpoints are mapped to the 'Shared' photo library in the iOS application and are unprotected. The `/private` endpoints are protected using Mobile Client Access and are mapped to the 'My Album' photo library in the iOS applicatiion. The backend maps requests from thes REST API to requests using the `bluemix-objectstorage` nodejs SDK. For more information regarding the REST API exposed by the nodejs backend, refer to the `swagger.yaml` file contained within the project

### Run the sample iOS application
When you run the sample iOS application you will be presented with two tabs. The initial screen is the into a 'Shared' photo library. The second tab will bring up a private photo library that maps to the user. If the user has not authenticated, then a login screen will be presented when the user attempts to view the 'My Album' tab. The login screen authenticates a user using the `userRepository` defined in the custom identity provider.

### License
This package contains sample code provided in source code form. The samples are licensed under the under the Apache License, Version 2.0 (the "License"). You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 and may also view the license in the license.txt file within this package. Also see the notices.txt file within this package for additional notices.
