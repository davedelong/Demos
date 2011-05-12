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

## Olympic Rings

A simple project showing simple drawing with CoreGraphics and a simple auto-reversing animation.

## Screenshot Detector

A simple project showing how to monitor for screenshots using a persistent `NSMetadataQuery`.