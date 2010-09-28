
Challenge your friends or create a zine with others all around the world in this digital zine (mini-magazine) app. 

As a new challenge is created, this application will fetch the latest list for you participate. Take a photo, draw a cartoon, finger paint a masterpiece or upload other artwork or photos from your iphone to compete in the challenges.

You'll be racing against the clock in some of the challenges, in others a slow and steady approach might be best.

Once you've created a zine, tap the submit button and you'll be able to share your zine-o-tron creation with your friends, or view it on-line.

Zine-o-tron was created by the Format Collective, a DIY (do it yourself) artist run collective based in Adelaide. They put on monthly DIY art, music and performance events in their multi-purpose space at 15 Peel Street, in the Adelaide CBD.
<a href="http://format.net.au" rel="nofollow">format.net.au</a>

The zine-o-tron project was a lucky recipient of funding from the Australia Council's Digital Culture Fund, which is a great supporter of indie arts projects.
<a href="http://artsdigitalera.com/dcfund" rel="nofollow">artsdigitalera.com/dcfund</a>

Published to the Apple AppStore as "Zine-O-Tron" http://bit.ly/zine-o-tron_app

++++++

This project uses several external services to provide it's infrastructure. You will need to
create accounts and sign up to these services to enable this functionality.

All account details are set in "Classes/Konstants.h"

== Flickr : http://www.flickr.com
Provides comic repository for images and metadata within the Collections, Sets and Tags.

Requires:
 kOBJECTIVE_FLICKR_API_KEY             
 kOBJECTIVE_FLICKR_API_SHARED_SECRET   
 kOBJECTIVE_FLICKR_API_AUTH_TOKEN      
 kOBJECTIVE_FLICKR_API_USER            

EG. http://www.flickr.com/services/apps/72157623984491646/

== Flurry: http://dev.flurry.com
Provides user analytics to track application usage

Requires:
 kFLURRY_ID

== UrbanAirship: https://go.urbanairship.com
Provides Push Notification Service; provide 1,000,000 free notification per month.

Requires:
 kAUApnsKey
 kAUApnsSecret

Sample UrbanAirship Payload:
 {"aps": {"badge": "+1", "alert": "New Challenge Available", "sound": "bite.caf"}}

Available Sounds:
 bite.caf, cat.caf, cow.caf, frog.caf, pig.caf

== Facebook App: http://www.facebook.com/developers/apps.php
Provides means to pst to FB Users feeds.

Requires:
 kFbApiKey
 kFbApiKey


== Badges: Business Rules
 - NewBadge : current_time < start_time
 - OpenBadge : current_time > start_time && current_time < finish_time
 - TimeBadge: current_time >  finish_time - 0.2 * (finish_time - start_time) (ie. within 20% of finish_time)
 - ClosedBadge: current_time > finish_time 

== Lables 
 - DoneBadge

== Links
http://bit.ly/zine-o-tron_app : Search AppStore for "zine-o-tron"
