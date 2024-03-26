Log.setLevel( "ALL" )

local imageNumber = 0
-- Create an instance of a viewer:
local myViewer = View.create( "2DImageDisplay" )
-- Create an instance of a code reader:
local myCodeReader = Image.CodeReader.create()
-- Create an instance of a decoder:
local myDecoderQR = Image.CodeReader.QR.create()
-- Add the decoder to the code reader:
myCodeReader:setDecoder( "APPEND", myDecoderQR )

local myGrayImage = nil
local myProcessingDelay = 1500
-- Create a timer to delay the start of image processing:
local myDelayTimer = Timer.create()
myDelayTimer:setExpirationTime( myProcessingDelay )   -- in [ms]
myDelayTimer:setPeriodic( false )

local function handleOnNewImage( inImage )
  --print( inImage:toString() )
  Log.info( inImage:toString() )
  -- Clear viewer from previously shown data:
  myViewer:clear()
  local myIconicID = myViewer:addImage( inImage )
  myViewer:present( "ASSURED" )
  myDelayTimer:start()
  -- Change the colored image to grayscale:
  myGrayImage = inImage:toGray()
end

local function processImage()
  myViewer:addImage( myGrayImage )
  local currCodeContent, currDuration = myCodeReader:decode( myGrayImage )
  print( "Code reading duration: " .. currDuration .. "ms;" )
  if ( #currCodeContent > 0 ) then
    print( "Number of codes read: " .. #currCodeContent .. ";" )
    for i = 1, #currCodeContent, 1 do
      Log.info( "Current code content (" .. i .. "): '" .. currCodeContent[ i ]:getContent() .. "';" )
    end
  else
    Log.warning( "No data code found in current image!" )
  end
  myViewer:present( "ASSURED" )
end
myDelayTimer:register( "OnExpired", processImage )

local function loadNextImage()
  if ( imageNumber == 0 ) then
    Log.warning( "Will start at first image!" )
  end
  print( "Will load image '" .. imageNumber .. ".png' ..." )
  local myImage = Image.load( "resources/" .. imageNumber .. ".png" )
  imageNumber = ( imageNumber + 1 ) % 13
  handleOnNewImage( myImage )
end

local imageTimer = Timer.create()
imageTimer:setExpirationTime( 3 * myProcessingDelay )   -- in [ms]
imageTimer:setPeriodic( true )
imageTimer:register( "OnExpired", loadNextImage )
Log.severe( "Timer has been registered!" )

local function main()
  print( "Hello world!" )
  local myText = "This is me!"
  print( "content of 'myText' is: '" .. myText .. "';" )
  imageTimer:start()
  loadNextImage()
end
Script.register( "Engine.OnStarted", main )
