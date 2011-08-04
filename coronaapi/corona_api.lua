analytics = {}
audio = {}
body = {}
crypto = {}
display = {}
easing = {}
event = {}
facebook = {}
file = {}
graphics = {}
group = {}
joint = {}
media = {}
movieclip = {}
myMap = {}
native = {}
network = {}
object = {}
openfeint = {}
package = {}
physics = {}
Runtime = {}
sprite = {}
spriteInstance = {}
spriteSheet = {}
stage = {}
store = {}
system = {}
timer = {}
transition = {}

function analytics.init( ) end
function analytics.logEvent( ) end
audio.ActiveMode = true
function audio.dispose( ) end
function audio.fade( ) end
function audio.fadeOut( ) end
function audio.findFreeChannel( ) end
audio.freeChannels = true
function audio.getDuration( ) end
function audio.getMaxVolume( ) end
function audio.getMinVolume( ) end
function audio.getSessionProperty() end
function audio.getVolume( ) end
function audio.isChannelActive( ) end
function audio.isChannelPaused( ) end
function audio.isChannelPlaying( ) end
function audio.loadSound( ) end
function audio.loadStream( ) end
audio.MediaPlaybackMixMode = true
function audio.pause( ) end
function audio.play( ) end
audio.PlayAndRecordMixMode = true
function audio.reserveChannels( ) end
audio.reservedChannels = true
function audio.resume( ) end
function audio.rewind( ) end
function audio.seek( ) end
function audio.setMaxVolume( ) end
function audio.setMinVolume( ) end
function audio.setSessionProperty() end
function audio.setVolume( ) end
audio.SoloAmbientMixMode = true
function audio.stop( ) end
function audio.stopWithDelay( ) end
function audio.totalChannels( ) end
function audio.unreservedFreeChannels( ) end
function audio.unreservedUsedChannels( ) end
function audio.usedChannels( ) end
function body.angularDamping( ) end
function body.angularVelocity( ) end
function body.bodyType( ) end
function body.isAwake( ) end
function body.isBodyActive( ) end
function body.isBullet( ) end
function body.isFixedRotation( ) end
function body.isSensor( ) end
function body.isSleepingAllowed( ) end
function body.linearDamping( ) end
function body:applyAngularImpulse( ) end
function body:applyForce( ) end
function body:applyLinearImpulse( ) end
function body:applyTorque( ) end
function body:getLinearVelocity( ) end
function body:resetMassData( ) end
function body:setLinearVelocity( ) end
function credits.init() end
function credits.requestUpdate() end
function credits.showOffers() end
function crypto.digest( ) end
function crypto.hmac( ) end
function crypto.md4( ) end
function crypto.md5( ) end
function crypto.sh1( ) end
function crypto.sha1( ) end
function crypto.sha224( ) end
function crypto.sha256( ) end
function crypto.sha384( ) end
function crypto.sha512( ) end
function display.captureScreen( ) end
function display.contentCenterX( ) end
function display.contentCenterY( ) end
function display.contentHeight( ) end
function display.contentScaleX( ) end
function display.contentScaleY( ) end
function display.contentWidth( ) end
function display.getCurrentStage( ) end
function display.loadRemoteImage( ) end
function display.newCircle( ) end
function display.newGroup( ) end
function display.newContainer() end
function display.newImage( ) end
function display.newImageRect( ) end
function display.newLine( ) end
function display.newRect( ) end
function display.newRoundedRect( ) end
function display.newText( ) end
function display.remove() end
function display.save( ) end
function display.screenOriginX( ) end
function display.screenOriginY( ) end
function display.setDefault( ) end
function display.setStatusBar( ) end
function display.statusBarHeight( ) end
function display.viewableContentHeight( ) end
function display.viewableContentWidth( ) end

display.BottomCenterReferencePoint = true
display.BottomLeftReferencePoint = true
display.BottomRightReferencePoint = true
display.captureScreen = true
display.CenterLeftReferencePoint = true
display.CenterReferencePoint = true
display.CenterRightReferencePoint = true
display.DarkStatusBar = true
display.DefaultStatusBar = true
display.HiddenStatusBar = true
display.TopCenterReferencePoint = true
display.TopLeftReferencePoint = true
display.TopRightReferencePoint = true
display.TranslucentStatusBar = true


function easing.inExpo( ) end
function easing.inOutExpo( ) end
function easing.inOutQuad( ) end
function easing.inQuad( ) end
function easing.linear( ) end
function easing.outExpo( ) end
function easing.outQuad( ) end
function error( ) end
function event.accuracy( ) end
function event.action( ) end
function event.altitude( ) end
function event.channel( ) end
function event.city( ) end
function event.cityDetail( ) end
function event.completed( ) end
function event.count( ) end
function event.country( ) end
function event.countryCode( ) end
function event.delta( ) end
function event.direction( ) end
function event.errorCode( ) end
function event.errorMessage( ) end
function event.force( ) end
function event.friction( ) end
function event.geographic( ) end
function event.handle( ) end
function event.id( ) end
function event.index( ) end
function event.invalidProducts( ) end
function event.isError( ) end
function event.isShake( ) end
function event.latitude( ) end
function event.longitude( ) end
function event.magnetic( ) end
function event.name( ) end
function event.object1( ) end
function event.object2( ) end
function event.other( ) end
function event.phase( ) end
function event.postalCode( ) end
function event.products( ) end
function event.region( ) end
function event.regionDetail( ) end
function event.source( ) end
function event.speed( ) end
function event.sprite( ) end
function event.street( ) end
function event.streetDetail( ) end
function event.target( ) end
function event.time( ) end
function event.transaction( ) end
function event.type( ) end
function event.url( ) end
function event.x( ) end
function event.xGravity( ) end
function event.xInstant( ) end
function event.xStart( ) end
function event.y( ) end
function event.yGravity( ) end
function event.yInstant( ) end
function event.yStart( ) end
function event.zGravity( ) end
function event.zInstant( ) end
function facebook.login( ) end
function facebook.logout( ) end
function facebook.request( ) end
function facebook.showDialog( ) end
function file:close( ) end
function file:flush( ) end
function file:lines( ) end
function file:read( ) end
function file:seek( ) end
function file:setvbuf( ) end
function file:write( ) end
function graphics.newMask( ) end
function group.numChildren( ) end
function group:insert( ) end
function group:remove( ) end
function joint.dampingRatio( ) end
function joint.frequency( ) end
function joint.getLimit( ) end
function joint.isLimitEnabled( ) end
function joint.isMotorEnabled( ) end
function joint.jointAngle( ) end
function joint.jointSpeed( ) end
function joint.jointTranslation( ) end
function joint.length( ) end
function joint.length1( ) end
function joint.length2( ) end
function joint.maxForce( ) end
function joint.maxMotorForce( ) end
function joint.maxMotorTorque( ) end
function joint.maxTorque( ) end
function joint.motorForce( ) end
function joint.motorSpeed( ) end
function joint.motorTorque( ) end
function joint:getAnchorA( ) end
function joint:getAnchorB( ) end
function joint:getLimits( ) end
function joint:getReactionForce( ) end
function joint:getRotationLimits( ) end
function joint:setLimits( ) end
function joint:setRotationLimits( ) end
function maptype( ) end
function media.getSoundVolume( ) end
function media.newEventSound( ) end
function media.newRecording( ) end
function media.pauseSound( ) end
function media.playEventSound( ) end
function media.playSound( ) end
function media.playVideo( ) end
function media.setSoundVolume( ) end
function media.show( ) end
function media.stopSound( ) end
function movieclip.newAnim( ) end
function myMap.isLocationVisible( ) end
function myMap.isScrollEnabled( ) end
function myMap.isZoomEnabled( ) end
function myMap.mapType( ) end
function myMap:addMarker( ) end
function myMap:getAddressLocation( ) end
function myMap:getUserLocation( ) end
function myMap:removeAllMarkers( ) end
function myMap:setCenter( ) end
function myMap:setRegion( ) end
function native.cancelAlert( ) end
function native.cancelWebPopup( ) end
function native.getFontNames( ) end
function native.newFont( ) end
function native.newMapView( ) end
function native.newTextBox( ) end
function native.newTextField( ) end
function native.setActivityIndicator( ) end
function native.setKeyboardFocus( ) end
function native.showAlert( ) end
function native.showWebPopup( ) end
native.systemFont = true
function network.download( ) end
function network.request( ) end
function object.align( ) end
function object.alpha( ) end
function object.contentBounds( ) end
function object.contentHeight( ) end
function object.contentWidth( ) end
function object.font( ) end
function object.hasBackground( ) end
function object.height( ) end
function object.inputType( ) end
function object.isHitTestable( ) end
function object.isSecure( ) end
function object.isVisible( ) end
function object.length( ) end
function object.maskRotation( ) end
function object.maskScaleX( ) end
function object.maskScaleY( ) end
function object.maskX( ) end
function object.maskY( ) end
function object.nextFrame( ) end
function object.parent( ) end
function object.play( ) end
function object.previousFrame( ) end
function object.reverse( ) end
function object.rotation( ) end
function object.size( ) end
function object.stageBounds( ) end
function object.stageHeight( ) end
function object.stageWidth( ) end
function object.strokeWidth( ) end
function object.text( ) end
function object.width( ) end
function object.x( ) end
function object.xOrigin( ) end
function object.xReference( ) end
function object.xScale( ) end
function object.y( ) end
function object.yOrigin( ) end
function object.yReference( ) end
function object.yScale( ) end
function object:addEventListener( ) end
function object:append() end
function object:contentToLocal( ) end
function object:dispatchEvent( ) end
function object:getParent( ) end
function object:getSampleRate( ) end
function object:getTunerFrequency( ) end
function object:getTunerVolume( ) end
function object:isRecording( ) end
function object:localToContent( ) end
function object:nextFrame( ) end
function object:play( ) end
function object:previousFrame( ) end
function object:removeEventListener( ) end
function object:removeSelf( ) end
function object:reverse( ) end
function object:rotate( ) end
function object:scale( ) end
function object:setDrag( ) end
function object:setFillColor( ) end
function object:setLabels( ) end
function object:setMask( ) end
function object:setReferencePoint( ) end
function object:setSampleRate( ) end
function object:setStrokeColor( ) end
function object:setTextColor( ) end
function object:startRecording( ) end
function object:startTuner( ) end
function object:stop( ) end
function object:stopAtFrame( ) end
function object:stopRecording( ) end
function object:stopTuner( ) end
function object:toBack( ) end
function object:toFront( ) end
function object:translate( ) end
function openfeint.downloadBlob( ) end
function openfeint.init( ) end
function openfeint.launchDashboard( ) end
function openfeint.launchDashboardWithAchievementsPage( ) end
function openfeint.launchDashboardWithChallengesPage( ) end
function openfeint.launchDashboardWithFindFriendsPage( ) end
function openfeint.launchDashboardWithListLeaderboardsPage( ) end
function openfeint.launchDashboardWithWhosPlayingPage( ) end
function openfeint.setHighScore( ) end
function openfeint.unlockAchievement( ) end
function openfeint.uploadBlob( ) end
function physics.addBody( ) end
function physics.addBody() end
function physics.getGravity() end
function physics.newJoint() end
function physics.pause() end
function physics.setDrawMode() end
function physics.setGravity() end
function physics.setPositionIterations() end
function physics.setScale() end
function physics.setVelocityIterations() end
function physics.start() end
function physics.stop() end
function Runtime:addEventListener( ) end
function sprite.add( ) end
function sprite.newSprite( ) end
function sprite.newSpriteSet( ) end
function sprite.newSpriteSheet( ) end
function sprite.newSpriteSheetFromData( ) end
function spriteInstance.animating( ) end
function spriteInstance.currentFrame( ) end
function spriteInstance.sequence( ) end
function spriteInstance:addEventListener( ) end
function spriteInstance:pause( ) end
function spriteInstance:play( ) end
function spriteInstance:prepare( ) end
function spriteSheet:dispose( ) end
function stage:setFocus( ) end
function store.canMakePurchases( ) end
function store.finishTransaction( ) end
function store.init( ) end
function store.loadProducts( ) end
function store.purchase( ) end
function store.restore( ) end
function system.activate() end
system.DocumentsDirectory = true
function system.getInfo( ) end
function system.getPreference( ) end
function system.getTimer( ) end
function system.hasEventSource() end
function system.openURL( ) end
function system.orientation( ) end
function system.pathForFile( ) end
system.ResourceDirectory = true
function system.setAccelerometerInterval( ) end
function system.setGyroscopeInterval() end
function system.setIdleTimer( ) end
function system.setLocationAccuracy( ) end
function system.setLocationThreshold( ) end
system.TemporaryDirectory = true
function system.vibrate( ) end
function timer.cancel( ) end
function timer.performWithDelay( ) end
function transition.cancel( ) end
function transition.dissolve( ) end
function transition.from( ) end
function transition.to( ) end
function value( ) end
