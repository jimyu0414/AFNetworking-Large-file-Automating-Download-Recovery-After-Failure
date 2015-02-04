# AFNetworking Large File Automating Download Recovery After Failure
This is a simple xcode project showing how to use AFNetworking library to manage large file download

------Features----
- automatically recover failures on behalf of the user when possible
- this project asynchronously downloads a content file forma an HTTP server when user presses a button
- When the application is closed in the middle of a transfer or when network connectivity disappears it save the state of the transer
- If the application has an unfinished download left over, it periodically poll the network to determine if the network is reachable.
If so, it attempt to resume the transfer.
