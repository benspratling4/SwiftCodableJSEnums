# SwiftDecodableJSEnums
 build tool to auto generate code that can decode javascript-style discriminated unions



So, you love that Swift has enums with associated values, and Decodable conformance synthesized by the compiler allows it to decode json.

Cool, right?

but your backend team has been doing things the sad javascript way and refuses to change, because they can't value a language which decreases work for the developers and increases reliability?

Tired of writing custom `init(from deocder:Decoder)throws` ?

Then this is a swift package plugin build tool for you!


As soon as I finish making it :-E



## How to

### Declare your enums

Declare your main enum with only one associated value type and no labels.
Declare it's support for Decodable.  All your cases must have 1 associated value, and all your associated values must be Decodable.


```swift
import Foundation
import MyCustomOtherFramework

public enum Transaction : Decodable {
	case add(NewItem)
	case delete(OldItemId)
	case update(Values)
}
```


Put it in a .swift file by itself with its name as the filename like `Transaction.swift`.
  
  
   
Declare an enum to represent the different values of your `type` value, inheriting from String and supporting Decodable.  If need be, add a coding keys with values that get transmitted over the wire. And also put it in a .swift file by itself with its name as its filename. 


`TransactionType.swift`:

```swift
import Foundation
import MyCustomOtherFramework

public enum TransactionType : String, Decodable {
	case add
	case delete
	case update
	
	enum CodingKeys : String, CodingKey {
		case add, delete = "remove"
		case update
	}
}
}
```



### Associate your enums

Now we have to associate these types in some way our build tool can recognize.

Now add a types.swiftJSEnums file to your project.

in it, write an extension on your main enum type declaring a var named `type` with your type name, like so:

```swift
extension Transaction { var type:TransactionType }
```

This isn't Swift, but it looks like Swift, and our module will also add this magic `type` property

Add all of these in one .swiftJSEnums file for your module.



### Now integrate the build tool





### Voila!

The build tool auto generates appropriate `init(from decoder:Decoder)throws` methods for you.

