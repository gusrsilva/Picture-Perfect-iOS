# Picture Perfect iOS

Picture Perfect is a smart camera application that takes the perfect picture
every time! It does this by using Apple's [CIDetector](https://developer.apple.com/reference/coreimage/cidetector/) image
processing class to determine when the person in the frame has both eyes open and
is smiling. Once these conditions are met, the picture is taken.

### How Do I Use It?

Using Picture Perfect is simple! When you first launch the app you will be taken
to the main camera screen

![Main Screen](/images/mockup/main.png)

Here you will see the camera preview, and three buttons. From left to right
these buttons are Settings, Activate/Deactivate detector, and flip camera. You will
notice the large button has the 🙈 emoji on it, this is one of the many emoji hints
that will appear on this button. This hint is telling you that the detector is not
currently active. (We will see a list of the emoji hints and their meanings later
when we visit the settings page).

Press the large button when you are ready to activate the detector.

![Detector Active](/images/mockup/detector_active.png)

The button will change color and begin pulsing the let you know detection is active. Different emoji hints will also appear. The two side buttons are disabled and made semi transparent to improve preview visibility. Now all you have to do is smile and the detector will recognize this and automatically take the picture!

### Viewing, Sharing, Saving, & Editing Your Photos

Once the picture is taken, you will be taken to the next screen to view it.

![View Taken Photo](/images/mockup/view_image.png)

Here, you can use the buttons in the bottom toolbar to (from left to right) share your image, save it to your camera roll, and edit your image with the [Img.ly Photo Editor SDK](https://www.photoeditorsdk.com/).

![Share Photo](/images/mockup/share.png)![Save Photo](/images/mockup/saved.png)![Edit Photo](/images/mockup/editor.png)

Once you are done viewing the image and want to return to the camera, simply press the back button in the top left corner.

### Settings

As previously mentioned, on the main screen you can press the button with the three dots to open the settings page.

![Settings Page](/images/mockup/settings.png)

This is were you can find the aforementioned list of the emoji hints and their
meaning. You can also set photos to save to your camera roll automatically after
saving and adjust the detector's sensitivity.


### Future Improvements

I am always open to suggestions and would love to hear ideas on how I could improve the app!

Some things I plan to add in the future are:
* Improve detector performance with multiple faces
* Option to take multiple photos in one session before being taken to image viewer
* Setting to select which conditions need to be met before photo is taken
* Back camera LED flash
* Front camera pseudo-flash
