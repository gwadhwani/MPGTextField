MPGTextField
=========

An autocomplete textfield for iOS which provides suggestions as you type. The textfield can be configured to ensure that a selection is compulsorily made from the list of suggestions and gives you control over the size of the popover showing suggestions based on the text entered by the user.

Usage
------------

MPGTextField is designed to be used in the simplest manner possible. Just copy the MPGTextField folder in your project and you are ready to use it. MPGTextField is a subclass of UITextField so you can set it up using storyboard or code - whichever suits you best. You will need to implement both <code>MPGTextFieldDelegate</code> and <code>UITextFieldDelegate</code> protocols in order to use MPGTextField delegate. The delegate comes with 1 required and few optional methods that are outlined below.

- <code> - (NSArray *)dataForPopoverInTextField:(MPGTextField *)textField</code> This is a required method that needs to be implemented by you. It is used to provide suggestions based on the text entered by the user. The <code>NSArray</code> should contain <code>NSDictionary</code> objects that are expected to have the following keys:
    - <code>DisplayText</code> - This is a required value. It is used to display the search suggestions to the user.
    - <code>DisplaySubText</code> (Optional) - This is used to display additional text (subtitle) with the search suggestions displayed by the MPGTextField.
    - <code>CustomObject</code> (Optional) - This is provided in case you use Core Data or require custom objects for auto complete textfield.

- <code> - (BOOL)textFieldShouldSelect:(MPGTextField *)textField </code> It is an optional method in the protocol. If you return YES, the textfield makes sure that a selection is made from the list of suggestions it shows to the user. The default is NO, i.e., if a user doesn't select any thing from the search suggestions, the textfield takes no action.

- <code>- (void)textField:(MPGTextField *)textField didEndEditingWithSelection:(NSDictionary *)result</code> If you return <code>YES</code> using <code>textFieldShouldSelect</code> protocol method, the textfield calls this method when a selection is made by the user or by the textfield. The <code>result</code> object is NSDictionary object that is selected from the suggestions list. If a user types in text that does not match any suggestions, the textfield will call the above method and set the <code>CustomObject</code> of the dictionary to be <code>NEW</code> 
