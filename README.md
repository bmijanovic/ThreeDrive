<img src="https://github.com/bmijanovic/ThreeDrive/assets/51921035/0edeb844-4960-4d3f-868e-3b4395f68d48" width="100" height="100">

# ThreeDrive
Introducing ThreeDrive, mobile application designed to revolutionize your cloud storage experience. ThreeDrive allows users to effortlessly upload and store various files, including images, documents... But ThreeDrive goes beyond standard storage; it enables easy file editing, secure sharing with family and friends, and even offers the unique Family Member Account feature, making collaboration a breeze. Powered by Amazon Web Services and lambda functions written in Python for a robust backend and a dynamic Flutter frontend for Android, ThreeDrive brings together efficiency, convenience, and security in a single user-friendly package. Say hello to a new era of cloud storage with ThreeDrive!

## Backend
ThreeDrive employs an Amazon serverless architecture for its backend, ensuring a highly scalable and efficient cloud storage solution. User data, along with directories and resource metadata, is stored in Amazon DynamoDB, providing reliable and persistent storage. Files are stored securely in Amazon S3 storage, enabling fast and easy uploads and retrievals.

The backend configuration is built using infrastructure as code, allowing for streamlined management and deployment processes. Asynchronous communication is facilitated, enabling concurrent task handling and improved system responsiveness.

For family member registration, Amazon Step Functions are utilized to simplify the process. Document uploads are efficiently managed using Amazon SQS for reliable transfer, while various notifications are sent using Amazon SNS.

To ensure data consistency and integrity, ThreeDrive's backend takes proactive measures to handle potential crashes or failures. In case of issues with Lambda functions, changes are effectively rolled back, preserving data and maintaining system stability.

## Web Frontend
The frontend of ThreeDrive is developed using the Flutter framework, a leading choice for building cross-platform mobile applications. Flutter allows ThreeDrive to offer a consistent and responsive user experience.

The design language follows the principles of Material Design, ensuring a visually appealing and intuitive interface. Material UI components are integrated throughout the application, enabling smooth user interactions and easy navigation.

## Screenshots
### File Preview And Upload
<img src="https://github.com/bmijanovic/ThreeDrive/assets/51921035/ed2d230d-e26b-4bde-8d71-07a19972c900" width="200">
<img src="https://github.com/bmijanovic/ThreeDrive/assets/51921035/b61b9112-a5ee-4d95-a7dc-8e4e720e7ee0" width="200">
<img src="https://github.com/bmijanovic/ThreeDrive/assets/51921035/5d2f100b-8a29-48fb-8fb6-f8500c66bde9" width="200">
<br/>
<space></space>
<img src="https://github.com/bmijanovic/ThreeDrive/assets/51921035/60a1f752-9177-4561-91ab-0953b8ba2f59" width="200">
<img src="https://github.com/bmijanovic/ThreeDrive/assets/51921035/de6d76e0-15a1-4576-b2f0-291f2d787fc1" width="200">
<br/>
<space></space>
<img src="https://github.com/bmijanovic/ThreeDrive/assets/51921035/2d0c209d-e4fa-422c-95ec-839124b547e4" width="200">
<img src="https://github.com/bmijanovic/ThreeDrive/assets/51921035/bdeaf62a-592b-473f-86fc-109cdc684301" width="200">

### Sharing And Family Members

<br/>
<img src="https://github.com/bmijanovic/ThreeDrive/assets/51921035/69777752-1f8a-4629-bd79-26d58b9f8d27" width="200">
<img src="https://github.com/bmijanovic/ThreeDrive/assets/51921035/b61251a4-cdbd-454e-abe8-9efe10568f1a" width="200">
<img src="https://github.com/bmijanovic/ThreeDrive/assets/51921035/44031711-fad3-4dea-b2d5-235d2f67ecf1" width="200">


## Authors

- [Jovan Jokić](https://github.com/jokicjovan)
- [Bojan Mijanović](https://github.com/bmijanovic)
- [Vukašin Bogdanović](https://github.com/vukasinb7)


