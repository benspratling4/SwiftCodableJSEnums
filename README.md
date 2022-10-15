# SwiftDecodableJSEnums
Synthesize `init(from decoder:Decoder)throws` methods to support JavaScript-style enums i.e. TypeScript-style "discriminated unions".


## Abstract

Swift's compiler-synthesized Decodable conformance for enums generates data structures which don't precisely match what JavaScript has been doing since before people learned how to properly structure data models.


## The problem this package plugin build tool solves

Consider this Swift enum with associated values:

```swift
enum Transaction : Decodable {
	case add(NewTransaction)
	case update(TransactionChange)
	case delete(TransactionDeletion)
}
struct NewTransaction : Decodable {
	var name:String
}
struct TransactionChange : Decodable {
	var id:String
	var name:String
}
struct TransactionDeletion : Decodable {
	var id:String
}

```


Swift's compiler would like you to use a json object like so:

```json
[
	{
		"add":{
			"_0": {
				"name":"Lunch Payment"
			}
		}
	},
	{
		"remove":{
			"_0": {
				"id":"5785e96a976f969869b6c86"
			}
		}
	},
]
``` 

which makes all the sense in the world, except for that `_0` thing...

But languages which don't understand types, like JavaScript, have been creating legacy API's that "can't break" that produce data structures like this:

```json
[
	{
		"type":"add",
		"name":"Lunch Payment"
	},
	{
		"type":"remove",
		"id":"5785e96a976f969869b6c86"
	},
]
```

And now TypeScript has cemented it in stone with a "discriminated unions" feature.  Which, philosophically, is very similar to Swift's "enums with associated values".
And unfortunately, there's no easy way to automatically adapt this poorly-chosen data model to Swift's fantastic features.

But using the power of Swift package plugin build tools and the public-source swift-syntax library, let's see if we can make an improvement!


## How to

### Declare your enums

#### Declare your main `enum` with associated values.
Declare it's support for `Decodable`.  All your cases must have 1 associated value, and all your associated values must be Decodable.

`Transaction.swift`
```swift
import Foundation
import MyCustomOtherFramework

public enum Transaction : Decodable {
	case add(NewItem)
	case delete(OldItemId)
	case update(Values)
}
```

Put it in a .swift file by itself with its name as the filename like `Transaction.swift`. Your enum can either be public or not.
You can add some other small things in the file, but no other enums!  (If we want to have bad compiler performance, we could loosen this restriction, _capisce_?)



#### Now we need an `enum` for the `type` property.

So in a new file, all by itself, declare an `enum`, backed by a `String`, and also conforming to `Decodable`.
If the string values different from the Swift identifiers for the cases, do the ` = "eribekgnj"` thing.
Also name this file the name of the type you create.  Our build tool's got to be able to spot the right file to read the values.

`TransactionType.swift`:
```swift
import Foundation
import MyCustomOtherFramework

public enum TransactionType : String, Decodable {
	case add
	case delete = "remove"
	case update
}
```

Ok, that's all for the legit swift.  Now we're going to create a special not-swift file.


### Associate your enums

We don't want the build tool to have to read every file in your project to figure out what's going on.  So we're going to create a special file which associates your main enum with your type enum.
Now add a `types.swiftJSEnums` file to your project.  The filename doesn't matter, the extension does.

In it, write an extension on your main enum type declaring a var named `type` with your type name, like so:

```swift
import Foundation
import MyCustomOtherFramework

extension Transaction { var type:TransactionType }
```

This isn't Swift, but it looks like Swift, and this build tool will legit add this actual property to your enum.
Put as many extension on as many enums in this file as you like.



### Now integrate the build tool

Add this build tool to your target like you would any other package plugin.  And see the `ExampleProject` for an example of a ...  project which uses the plguin.

```swift
.target(name: "ExampleProject"
		, plugins: [
			"SwiftDecodableJSEnums",
		]
),
```



### Voila!

No seriously, you're done.  The build tool auto generates appropriate `init(from decoder:Decoder)throws` methods for you.  It gets the `public` right, and it gets the imports right. 

