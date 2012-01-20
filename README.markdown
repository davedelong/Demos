# Demos

Some demos showing various concepts relating to Objective-C and Cocoa.

## AutozeroingArray

Contains:

1. An `NSMutableArray` subclass (`DDAutozeroingArray`) that maintains auto-zeroing weak references to its items.
2. An `NSMutableArray` category that allows you to create a "pure" `NSMutableArray` that maintains auto-zeroing weak references to its items.  This is slightly less efficient than a `DDAutozeroingArray`.

Both should work on both iOS and Mac OS X, regardless of GC mode.

## DDURLBuilder

`DDURLBuilder` is essentially a mutable `NSURL`.  You can use it to customize the host, path, query, fragment, username, password, etc of an `NSURL`.

## DynamicStorage

Contains `DDDynamicStorageObject`, an `NSObject` subclass that dynamically generates getters and setters for properties declared as `@dynamic`, and uses an  `NSMutableDictionary` as the backing store.

## FaultingArray

An `NSArray` subclass that only loads the objects in the array when something else needs them.

## GrandSuper

A project showing how to invoke "grandsuper" (super's super).  Uses a private method on `NSInvocation`, so you probably shouldn't use this in a production setting.

## JoinPoints

A **really really really** dangerous project that shows how to inject code before, after, and during any method call.

THIS IS A PROOF-OF-CONCEPT ONLY, and should **NOT** be used in any sort of production setting.

## Olympic Rings

A simple project showing simple drawing with CoreGraphics and a simple auto-reversing animation.

## Screenshot Detector

A simple project showing how to monitor for screenshots using a persistent `NSMetadataQuery`.