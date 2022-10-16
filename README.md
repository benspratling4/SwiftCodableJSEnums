# SwiftCodableJSEnums
Synthesize `Decodable` and `Encodable` conformance to support JavaScript-style enums i.e. TypeScript-style "discriminated unions".


## Abstract

Swift's compiler-synthesized `Decodable` and `Encodable` conforming methods for `enum`s generates data structures which don't precisely match what JavaScript has been doing since before people learned how to properly structure data models, i.e. deciding which fields are present based on the value of  a `"type"` property.  This package plugin build tool creates ones which do support the JavaScript style data models.


## The problem this package plugin build tool solves

Swift `enum`s with associated values are fantastic because they eliminate code paths with unvalidated inputs when there are a finite number of code situations with distinct values associated with each code path.

Consider this Swift enum with associated values:

```swift
enum Transaction : Decodable {
	case add(NewTransaction)
	case update(TransactionChange)
	case delete(id:String)
}
struct NewTransaction : Decodable {
	var name:String
}
struct TransactionChange : Decodable {
	var id:String
	var name:String
}

```

And normally, we push back validation of our values and code paths as far as we can, often up to the deserialization of incoming data.  So looking at what the Swift compiler would like you to do for your json, it would need to look like this:

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
		"delete":{
			"id":"5785e96a976f969869b6c86"
		}
	},
]
``` 

which makes all the sense in the world, because you know the types when you begin decoding them, instead of changing the type of the thing based on values of children. (except for that `_0` thing..., and there's a reason for that; it's just 🤦‍♂️)


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

Which looks simple, but is philosophically disgusting because...  it changes types based on the value of its children.  🤦‍♂️
And now TypeScript has cemented it in stone with a "discriminated unions" feature.  Which, philosophically, is very similar to Swift's "enums with associated values" in terms of being able to lock down a finite a number of code paths with distinct guaranteed values.
And unfortunately, there's no easy way to automatically adapt this poorly-chosen data model to Swift's fantastic features.

But using the power of Swift package plugin build tools and Apple's public-source swift-syntax library, SwiftCodableJSEnums will come to your rescue!


## How to use SwiftCodableJSEnums

### Declare your enums

#### Declare your main `enum` with associated values.

Declare it's support for `Codable` (or `Decodable` or `Encodable`).

For your arguments.  First of all, they all need to be at least as `Decodable` or `Encodable` as your `enum`.
Second, you have 2 choices for how you want to handle labels.  Swift `enum`s can support any number of labeled or unlabeled arguments in `enum` `case`s.  However, that doesn't make sense here.

 - If you have a small number of arguments, you may want to declare them directly in the `enum`; just make sure they're labeled, like the 'delete` case in the example below.
 - If you have complex types, wrap them up into another type, and declare one unlabeled argument with that type, such as the `add` or `update` `case`s in the example below.
 
 So what we're _not_ supporting is any unlabeled arguments if there's more than 1 argument.  And that's exactly why Swift was generating the `"_0"` label (`_` meaning "unlabeled", and `0` meaning "first"), which we are _not_ doing. 

`Transaction.swift`
```swift
import Foundation
import MyCustomOtherFramework

public enum Transaction : Codable {
	case add(NewItem)
	case delete(id:String)
	case update(Values)
}
```

Put it in a .swift file by itself with its type name as the filename like `Transaction.swift`. Your `enum` can either be `public` or not.
You can add some other small things in the file, but no other enums!  (If we want to have bad compiler performance, we could loosen this restriction, _capisce_?)



#### Now we need an `enum` for the `type` property.

This enum will be what we decode or encode for the value of the `type` property.
So in a new file, all by itself, declare an `enum`, backed by a `String`, and with matching conformances to `Decodable`, `Encodable` or `Codable`.
Give it cases which match the cases in your original `enum`, but no associated values.
If the string values differ from the Swift identifiers for the cases, do the `case camelCase = "1nva11d SCREAMING_snake-shishka-BOB"` thing.
Also name this file the name of the type you create.  Our build tool's got to be able to spot the right file to read the values.

`TransactionType.swift`:
```swift
import Foundation
import MyCustomOtherFramework

public enum TransactionType : String, Codable {
	case add
	case delete = "remove"
	case update
}
```

Ok, that's all for the legit Swift.  Next we're going to create a special not-Swift file.


### Associate your `enum`s

We don't want the build tool to have to read every file in your project to figure out what's going on.  So we're going to create a special file which associates your main `enum` with your type `enum`.
Now add a `types.swiftJSEnum` file to your project.  The filename doesn't matter, the extension does.

In it, write an extension on your main `enum` type declaring a `var` named `type` with your type name, like so:

```swift
import Foundation
import MyCustomOtherFramework

extension Transaction { var type:TransactionType }
```

And you're like "you can't add stored properties in extensions!"  Yes, but hold on; this isn't Swift.  It just looks like Swift so you know if you're typing it right.  The SwiftCodableJSEnums Swift package plugin build tool will legit add this actual property to your `enum` in a Swift file it generates when it runs.
Put as many `extension`s on as many `enum`s in this file as you like.

And technically, you can change the name of the `type` property, too.


### Now add the build tool to your target

Add this build tool to your target like you would any other package plugin.  And see the `ExampleProject` target for an ...  example ... of a ... project which uses the plguin.

```swift
.target(name: "ExampleProject"
		, plugins: [
			"SwiftCodableJSEnums",
		]
),
```


### Voila!

Now you can `JSONDecoder()` or `JSONEncoder()` like a normal person.  The build tool synthesizes a .swift file which includes a `init(from decoder:Decoder)throws` method and or `func encode(to encoder: Encoder) throws` method for you which understands the JavaScript-style data models.  It gets the `public` right, and it uses the imports from your `.swiftJSEnum` file so you can name-space appropriately.  It also actually creates the `var type` property you made the fake extension for, so you can read that property, as if you needed to.

Want to ignore unknown values for your `type` property when deserializing an array?  Check out https://github.com/benspratling4/SwiftPatterns/blob/master/Sources/SwiftPatterns/SkippingDecodeErrors.swift .  
