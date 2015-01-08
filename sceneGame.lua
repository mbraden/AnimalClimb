local composer = require( "composer" )
local scene = composer.newScene()
local widget = require("widget")
local buttonLeft, buttonRight, buttonFire, buttonPause, divLine
local currentImage = 1
local timerMain
local sheetFlyingBird
local sheetFlyingBird2
local sheetGuyWalk
local seqflyingbird
local seqflyingbird2
local seqguywalk
local spriteFlyingBird
local spriteFlyingBird2
local spriteGuyWalk
local tableAnimals = {}
local tableStack1 = {}
local sceneGroupGlobal
local divLineSpace = 73
local bPaused = false



-----------------------------------------
-------    PAUSE BUTTON PRESSED
-----------------------------------------
local function handleButtonPauseEvent( event)
    if (event.phase == "ended") then
        if (bPaused == false) then
            x = timer.pause(timerMain)
            bPaused = true
        else
            x = timer.resume(timerMain)
            bPaused = false
        end
        
    end
end



-----------------------------------------
-------    LEFT BUTTON PRESSED
-----------------------------------------
local function handleButtonLeftEvent( event)
    if (event.phase == "ended") then        
        tableAnimals[currentImage].isVisible = false
        currentImage = currentImage - 1
        if (currentImage < 1) then
            currentImage = table.maxn(tableAnimals)
        end
        tableAnimals[currentImage].isVisible = true
    end
end

-----------------------------------------
-------    RIGHT BUTTON PRESSED
-----------------------------------------
local function handleButtonRightEvent( event)
    if (event.phase == "ended") then        
        tableAnimals[currentImage].isVisible = false
        currentImage = currentImage + 1
        if (currentImage > table.maxn(tableAnimals)) then
            currentImage = 1
        end
        tableAnimals[currentImage].isVisible = true
    end
end


-----------------------------------------
-------    FIRE BUTTON PRESSED
-----------------------------------------
local function handleButtonFireEvent( event)
    if (event.phase == "ended") then

        --LOOP THROUGH THE STACK REMOVING ALL THE ONES THAT MATCH WHAT WAS CLICKED       
        local count
        for count = table.maxn(tableStack1) , 1, -1 do            --THIS GOES IN REVERSE SO THAT AS THEY ARE REMOVED, THERE ARE ALWAYS MORE BELOW
            if (tableStack1[count].sequence == tableAnimals[currentImage].sequence) then
                tableStack1[count]:removeSelf() --THIS REMOVES THE SPRITE
                table.remove(tableStack1, count)  --THIS REMOVES THE ELEMENT FROM THE TABLE
            end            
        end

        --NOW DROP ALL LEFT DOWN
        dropRemainingAnimals()


    end
end

function dropRemainingAnimals()
    if (table.maxn(tableStack1) > 0) then

        --LOOP THROUHG LIST FROM BOTTOM(1) TO TOP COLLAPSING THE ANIMALS
        local count, newSpriteY
        print(" ")        
        for count=1, table.maxn(tableStack1), 1 do
            
            if (count == 1) then
                transition.cancel("falling") --THIS CANCELS ANIMALS FALLING FROM TIMER DROP
                newSpriteY = divLine.y - divLineSpace 
                print("IDX:"..count..",  MOVING FROM:"..tableStack1[count].y.." TO:"..newSpriteY)
                transition.to(tableStack1[count], { time=150, y=newSpriteY, transition=easing.inQuad } )
            else
                transition.cancel("falling") --THIS CANCELS ANIMALS FALLING FROM TIMER DROP
                newSpriteY = getUpperYShouldBeBasedOnLowerY(count-1, count,  newSpriteY, tableStack1)
                print("IDX:"..count..",  MOVING FROM:"..tableStack1[count].y.." TO:"..newSpriteY)
                transition.to(tableStack1[count], { time=150, y=newSpriteY, transition=easing.inQuad  } )
                
            end
            
        end
        print(" ")
        print(" ")
        print(" ")

        --x = timer.pause(timerMain)

    end
end




-------------------------------------------------------------------
--       CALCULATE WHAT Y VALUE SHOULD BE FOR COLLAPSING ANIMALS
-------------------------------------------------------------------
function getUpperYShouldBeBasedOnLowerY(indexLower, indexUpper, lowerYShouldBe, stack)
    local halfHeightLower, halfHeightUpper, upperY
    halfHeightLower = math.round((stack[indexLower].height * stack[indexLower].yScale) * .5)
    halfHeightUpper = math.round((stack[indexUpper].height * stack[indexUpper].yScale) * .5)    
    upperY = lowerYShouldBe - halfHeightLower - halfHeightUpper
    return upperY
end




-------------------------------------------------------
--       GAME LISTENERS FUNCTION TO START ALL TIMERS, ETC...
--------------------------------------------------------
function gameListeners(cmd)
    if (cmd == "start") then
        timerMain = timer.performWithDelay(2000, addAnimalToStack, 0 )
    else
        timerMain = nil
    end
end



------------------------------------------------------
--          ADD NEW RANDOM ANIMAL TO STACK
-------------------------------------------------------
function addAnimalToStack()
    

    --get the random number(animal)
    local x = math.random(table.maxn(tableAnimals))
    
    

    --INSERT THE RANDOM ANIMAL INTO THE STACKTABLE
    --table.insert(tableStack1, tableAnimals[x] )


    --print("DATA:"..tableStack1[table.maxn(tableStack1)].sequence)
    --print("count elements:"..table.maxn(tableStack1))



    --CREATE TEMP COPY OF RANDOMLY SELECTED SPRITE
    local spriteTemp 
    local seq = tableAnimals[x].sequence 
    if (seq == "seqflyingbird") then
        spriteTemp = display.newSprite(sheetFlyingBird, seqflyingbird)
    elseif (seq == "seqflyingbird2") then
        spriteTemp = display.newSprite(sheetFlyingBird2, seqflyingbird2)
    elseif (seq == "seqguywalk") then
        spriteTemp = display.newSprite(sheetGuyWalk, seqguywalk)
    end
    spriteTemp:scale(tableAnimals[x].xScale, tableAnimals[x].yScale)    
    spriteTemp.x = display.contentWidth * .5
    spriteTemp.y = 0
    sceneGroupGlobal:insert(spriteTemp)
    spriteTemp:play()

--MIKE 2:

    --SET NEW SPRITE Y POSITION
    local newSpriteY    
    if (table.maxn(tableStack1) == 0) then
        --FIRST ANIMAL IN STACK
        newSpriteY = divLine.y - divLineSpace
    else
        local lastSprite = tableStack1[table.maxn(tableStack1) ]        
        local lastSpriteScaleY = lastSprite.yScale
        local lastSpriteHeight = math.round(lastSprite.height * lastSpriteScaleY)
        local lastSpriteY = lastSprite.y        
        local newSpriteScaleY = spriteTemp.yScale
        local newSpriteHeight = math.round(spriteTemp.height * newSpriteScaleY)
        newSpriteY = lastSpriteY - (lastSpriteHeight*.5) - (newSpriteHeight*.5)        
        newSpriteY = newSpriteY + 10
        print("Dropping Animal To "..newSpriteY.." because of last sprite being at "..lastSpriteY)
    end

    
    --NOW DROP THE SPRITE DOWN ONTO THE STACK
    transition.to(spriteTemp, { time=500, y=newSpriteY, transition=easing.inQuad, tag="falling" } )
    

        

    if (newSpriteY < 0) then
        endGame()
    end

    --ADD THE COPY OF THE SPRITE TO THE REAL STACK
    table.insert(tableStack1, spriteTemp)


end



local listenerTransitionDone = function(obj)
    print("Transition Complete")
end




------------------------------------------------------------
--         END GAME
------------------------------------------------------------
function endGame()
    gameListeners("end")    
    composer.gotoScene( "sceneMenu", "slideRight", 800  )
end









--SCENE CREATE
function scene:create( event )

    sceneGroupGlobal = self.view
    
    --SET RANDOM SEED
    math.randomseed(os.time())

    --LOAD ALL SPRITE STUFF
    loadSprites(sceneGroupGlobal)



    --START THE TIMERS
    gameListeners("start")

    
end




--------------------------------------
--         LOAD SPRITE STUFF
--------------------------------------
function loadSprites(sceneGroup)

    --PAUSE BUTTON
    buttonPause = widget.newButton {
        id = "buttonpause",
        x = 40,
        y = 50,
        defaultFile = "assets/btnfire.png",
        onEvent = handleButtonPauseEvent
    }

    --LEFT BUTTON
    buttonLeft = widget.newButton {         
        id = "buttonleft", 
        x = display.contentWidth * .20,
        y = display.contentHeight - 175,        
        defaultFile = "assets/btnleft.png",
        overFile = "assets/btnleft_pressed.png",
        onEvent = handleButtonLeftEvent
    }
    sceneGroup:insert(buttonLeft)

    --RIGHT BUTTON
    buttonRight = widget.newButton {         
        id = "buttonright", 
        x = display.contentWidth * .80,
        y = display.contentHeight - 175,        
        defaultFile = "assets/btnright.png",
        overFile = "assets/btnright_pressed.png",
        onEvent = handleButtonRightEvent
    }
    sceneGroup:insert(buttonRight)


    --FIRE BUTTON
    buttonFire = widget.newButton {         
        id = "buttonfire", 
        x = display.contentWidth * .50,
        y = display.contentHeight - 175,        
        defaultFile = "assets/btnfire.png",
        overFile = "assets/btnfire.png",
        onEvent = handleButtonFireEvent
    }
    sceneGroup:insert(buttonFire)




    --IMAGE SHEET OF FLYING BIRD 1
    local optionsFlyingBird = 
    {
        width = 240,
        height = 314,
        numFrames = 22
    }
    sheetFlyingBird = graphics.newImageSheet("assets/birdsheet1.png", optionsFlyingBird)


    --IMAGE SHEET OF FLYING BIRD 2
    local optionsFlyingBird2 = 
    {
        width = 110,
        height = 101,
        numFrames = 14
    }
    sheetFlyingBird2 = graphics.newImageSheet("assets/birdsheet2.png", optionsFlyingBird2)
    
    --IMAGE SHEET OF GUYWALK
    local optionsGuyWalk = 
    {
        width = 58,
        height = 87,
        numFrames = 8
    }
    sheetGuyWalk = graphics.newImageSheet("assets/guywalksheet.png", optionsGuyWalk)






    --SEQUENCE FOR FLYING BIRD
    seqflyingbird = 
    {
        {
            name = "seqflyingbird",
            start = 1,
            count = 22,
            time = 650,
            loopCount = 0,
            loopDirection = "forward"
        }
    }


    --SEQUENCE FOR FLYING BIRD 2
    seqflyingbird2 = 
    {
        {
            name = "seqflyingbird2",
            start = 1,
            count = 14,
            time = 650,
            loopCount = 0,
            loopDirection = "forward"
        }
    }

    --SEQUENCE FOR GUY WALK
    seqguywalk = 
    {
        {
            name = "seqguywalk",
            start = 1,
            count = 8,
            time = 650,
            loopCount = 0,
            loopDirection = "forward"
        }
    }




    --SPRITE FOR FLYING BIRD
    spriteFlyingBird = display.newSprite(sheetFlyingBird, seqflyingbird)
    spriteFlyingBird:scale(.5, .5)
    sceneGroup:insert(spriteFlyingBird)
    spriteFlyingBird.x = display.contentWidth * .5
    spriteFlyingBird.y = buttonFire.y - 190
    tableAnimals[1] = spriteFlyingBird
    tableAnimals[1].isVisible = true
    spriteFlyingBird:play()

    --SPRITE FOR FLYING BIRD 2
    spriteFlyingBird2 = display.newSprite(sheetFlyingBird2, seqflyingbird2)    
    spriteFlyingBird2:scale(1, 1)
    sceneGroup:insert(spriteFlyingBird2)
    spriteFlyingBird2.x = display.contentWidth * .5
    spriteFlyingBird2.y = buttonFire.y - 190
    tableAnimals[2] = spriteFlyingBird2
    tableAnimals[2].isVisible = false
    spriteFlyingBird2:play()

    --SPRITE FOR GUY WALK
    spriteGuyWalk = display.newSprite(sheetGuyWalk, seqguywalk)    
    spriteGuyWalk:scale(.75, .75)
    sceneGroup:insert(spriteGuyWalk)
    spriteGuyWalk.x = display.contentWidth * .5
    spriteGuyWalk.y = buttonFire.y - 190
    tableAnimals[3] = spriteGuyWalk
    tableAnimals[3].isVisible = false
    spriteGuyWalk:play()


    --SEPARATING LINE
    divLine = display.newRect(display.contentWidth*.5, spriteFlyingBird.y - (math.round((spriteFlyingBird.height * spriteFlyingBird.yScale) * .5)) , display.contentWidth, 10)
    divLine:setFillColor(55,55,55,256)
    sceneGroup:insert(divLine)



end



-- "scene:show()"
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase


    

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen).
    elseif ( phase == "did" ) then
        composer.removeScene( "sceneMenu" )
        -- Called when the scene is now on screen.
        -- Insert code here to make the scene come alive.
        -- Example: start timers, begin animation, play audio, etc.
    end
end


-- "scene:hide()"
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is on screen (but is about to go off screen).
        -- Insert code here to "pause" the scene.
        -- Example: stop timers, stop animation, stop audio, etc.
    elseif ( phase == "did" ) then
        -- Called immediately after scene goes off screen.
    end
end


-- "scene:destroy()"
function scene:destroy( event )

    local sceneGroup = self.view

    -- Called prior to the removal of scene's view ("sceneGroup").
    -- Insert code here to clean up the scene.
    -- Example: remove display objects, save state, etc.
end


-- -------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-- -------------------------------------------------------------------------------

return scene