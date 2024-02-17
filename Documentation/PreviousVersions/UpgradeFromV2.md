# <img valign='top' src="https://what3words.com/assets/images/w3w_square_red.png" width="64" height="64" alt="what3words">&nbsp;Upgrading from v2 to v3

There is also an [upgrading from v1 to v2](UpgradeFromV1.md) readme.

Overview
--------

The 3rd version of this library uses our what3words v4 interface.  In the old interface, countries and languages were specified as a `String` containing a two letter code.

These are now structs that conform to the protcols `W3WCountry` and `W3WLanguage`.  The API will give you `W3WApiCountry` and the SDK will give you `W3WSdkLanguage`.  There are also conveneice structs called things like `W3WBaseCountry`.

Also, distance used to be specified as an Int or Float representing the number of kilometers or meters.  but, now a distance is represented by any class conforming to our W3WDistance protocol.  These can generally be created with any units, and will return any unit needed:

```
let distance = W3WBaseDistance(feet: 1000.0)
print(distance.meters)
```

Installing
----------

Use Swift Package Manager to install this library.  See the instructions in our [documentation](https://github.com/what3words/w3w-swift-components/blob/master/Documentation/autosuggest.md).

