MPGTextField
=========

<p align="center"><img src = "https://dl.dropboxusercontent.com/u/90817764/MPGTextField.png" width=320  height = 568 align="center"></p>

An autocomplete textfield for iOS which provides suggestions as you type. The textfield can be configured to ensure that a selection is compulsorily made from the list of suggestions and gives you control over the size of the popover showing suggestions based on the text entered by the user.

Usage - Swift
------------
Using MPGTextField in Swift is even more simpler, thanks to awesome improvements in Xcode 6. Now you can set the background color, seperator color and popover frame all from Storyboard. Just copy the MPGTextField_Swift.swift file in your project and you are ready to implement auto complete functionality in your app. You will need to implement `MPGTextFieldDelegate` methods to use the text field's autocomplete feature. Like Objective C, it has the following methods

- `func dataForPopoverInTextField(textfield: MPGTextField_Swift) -> Dictionary<String, AnyObject>[]` This is a required method. The functionality is the same as its Obj-C counterpart and it expects an array of Dictionary objects that have `DisplayText`, `DisplaySubText` and `CustomObject` keys, where 'DisplayText' is a mandatory key.

- `func textFieldDidEndEditing(textField: MPGTextField_Swift, withSelection data: Dictionary<String,AnyObject>)` Optional method that is called if the textfield needs to compulsorily select a result from the search suggestions. Note that this method returns the object selected by the user or selected by the textfield for you or a new object where the `CustomObject` key is set to `NEW`

- `func textFieldShouldSelect(textField: MPGTextField_Swift) -> Bool` Optional method that tells the textfield if a selection should be made even if user doesn't select anything from the search results. 

Usage - Objective C
------------

MPGTextField is designed to be used in the simplest manner possible. Just copy the MPGTextField folder in your project and you are ready to use it. MPGTextField is a subclass of UITextField so you can set it up using storyboard or code - whichever suits you best. You will need to implement both <code>MPGTextFieldDelegate</code> and <code>UITextFieldDelegate</code> protocols in order to use MPGTextField delegate. The delegate comes with 1 required and few optional methods that are outlined below.

- `(NSArray *)dataForPopoverInTextField:(MPGTextField *)textField` This is a required method that needs to be implemented by you. It is used to provide suggestions based on the text entered by the user. The <code>NSArray</code> should contain `NSDictionary` objects that are expected to have the following keys:
    - `DisplayText` - This is a required value. It is used to display the search suggestions to the user.
    - `DisplaySubText` (Optional) - This is used to display additional text (subtitle) with the search suggestions displayed by the MPGTextField.
    - `CustomObject` (Optional) - This is provided in case you use Core Data or require custom objects for auto complete textfield.

- `(BOOL)textFieldShouldSelect:(MPGTextField *)textField ` It is an optional method in the protocol. If you return YES, the textfield makes sure that a selection is made from the list of suggestions it shows to the user. The default is NO, i.e., if a user doesn't select any thing from the search suggestions, the textfield takes no action.

- `(void)textField:(MPGTextField *)textField didEndEditingWithSelection:(NSDictionary *)result` If you return <code>YES</code> using <code>textFieldShouldSelect</code> protocol method, the textfield calls this method when a selection is made by the user or by the textfield. The <code>result</code> object is NSDictionary object that is selected from the suggestions list. If a user types in text that does not match any suggestions, the textfield will call the above method and set the <code>CustomObject</code> of the dictionary to be <code>NEW</code> 


License
-------
The MIT License (MIT)

Copyright (c) 2014 Gaurav Wadhwani

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
