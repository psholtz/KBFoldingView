KBFoldingView
============= 

![http://farm8.staticflickr.com/7374/8729195157_ec0c72f651_o.gif](http://farm8.staticflickr.com/7374/8729195157_ec0c72f651_o.gif)

KBFoldingView is an easy-to-use category on UIView that facilitates stunning onscreen transitions between views on iOS.

KBFoldingView draws much of its inspiration from the very excellent <a href="https://github.com/xyfeng/XYOrigami" target=_blank>XYOrgami</a> by <a href="https://github.com/xyfeng" target=_blank>xyfeng</a> on github. 

Example Usage
------------- 

The folding category works by invoking the category method on the "source" view (or the view which is initially displayed on screen), and passing as an argument the "destination" view which is to be rendered onscreen after the view transition has terminated.

The basic idea is something like this:

<pre>
UIView *srcView = ...;
UIView *destView = ...;

[srcView showFoldingView:destView];
</pre>

While the API will work as indicated above, it should be noted that what is described above is an (extremely) simple "default" implementation: the number of folds in the transition is hard-coded, the duration of the fold is hard-coded and the direction from the destination view appears onscreen is hard-coded. 

Nearly all users will want the flexibility to configure all three of these parameters dynamically, and will thus want to use the more robust versions of these APIs where these values can be configured manually:

<pre>
[srcView showFoldingView:destView
                   folds:folds
               direction:direction
                duration:duration
            onCompletion:completionBlock];
</pre>

The <code>duration</code> variable is of type **NSTimeInterval**, <code>direction</code> and <code>folds</code> are both of type **NSUInteger**, and the signature of the optional completion block is <code>(void (^)(BOOL completed))</code>.  Users can set the compiler flag <code>kbFoldingViewUseBoundsChecking</code> to **TRUE** if they want to prevent non-sensical values for duration, direction and fold from being passed into the API.

Support
------- 

KBFoldingView is designed to run on all iOS devices (iPhone4, iPhone5 and iPad), and on all iOS versions from 5.0 and up.

KBFoldingView is designed to be used on ARC-enabled projects.

KBFoldingView requires linking with the QuartzCore Framework.

License
------- 

The code is distributed under the terms and conditions of the MIT license.

Change Log
---------- 

**Version 1.1** @ February 11, 2015

<ul>
<li>Support for iOS7, iOS8.</li>
<li>Other minor updates.</li>
</ul>

**Version 1.0** @ May 11, 2013

<ul>
 <li>Initial Release.</li>
</ul>

Acknowledgements
---------------- 

I undertook this project largely as an attempt to understand more thoroughly how 3D transformations work in CoreGraphics and Quartz. Much of the inspiration for this code comes from the very excellent <a href="https://github.com/xyfeng/XYOrigami" target=_blank>XYOrgami</a> by <a href="https://github.com/xyfeng" target=_blank>xyfeng</a>. What I've done here amounts to little more than a refactoring of his code to improve its readability, maintainability and integrability, as well as adding a few minor features of my own that I found useful. The <a href="https://github.com/honcheng/PaperFold-for-iOS" target=_blank>PaperFold-for-iOS</a> and <a href="https://github.com/honcheng/PaperFoldMenuController" target=_blank>PaperFoldMenuController</a> projects by <a href="https://github.com/honcheng/" target=_blank>honcheng</a> are also great learning resources.