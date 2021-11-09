//! Copyright (C) 2018 Tomasz Korzec <tom@shmo.de>
//!
//! This program is free software: you can redistribute it and/or modify it
//! under the terms of the GNU General Public License as published by the Free
//! Software Foundation, either version 3 of the License, or (at your option)
//! any later version.
//!
//! This program is distributed in the hope that it will be useful, but WITHOUT
//! ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
//! FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
//! more details.
//!
//! You should have received a copy of the GNU General Public Lice

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Math as Math;
using Toybox.Activity as Act;
using Toybox.Application.Storage;
using Toybox.System;

class EveryTileView extends Ui.DataField {
    hidden var tileWidth = 50;
    hidden var tileHeight = 50;
    hidden var initialized = false;

    hidden var finePath;          // fine path
    hidden var coarsePath;         // coarse path

    hidden var tx = new[6]; // coordinates of tiles on the screen
    hidden var ty = new[6];
    hidden var displaySizeX = 0;      // screen size
    hidden var displaySizeY = 0;
    hidden var heading = 0.0;
    hidden var mainMap;          // main map object
    hidden var landscapeMode=false;
    hidden var displayMiddleX;
    hidden var displayMiddleY;
    hidden var singleDataField = true;
    
    hidden var lastPauseClick = 0;
    hidden var zoomMode = false;
    hidden var redoLayout = false;
    hidden var standardTileHeight = tileHeight;


    function initialize()
    {
       DataField.initialize();
       mainMap = new map();
       finePath = new path(50,mainMap.hlon,mainMap.hlat);
       coarsePath= new path(200,mainMap.hlon,mainMap.hlat);

       initialized=false;

       var inf = Act.getActivityInfo();
       if( (inf!=null) && (inf.elapsedTime > 10000) )
       {
          // attempt to continue activity
          mainMap.newTiles=Storage.getValue("newTiles");
          mainMap.newTilesR=Storage.getValue("newTilesR");
          if( coarsePath.load() && (mainMap.newTiles!=null) && (mainMap.newTilesR!=null) )
          {
             finePath.set(0,coarsePath.getDeg(null));
             mainMap.setMap(finePath.p[0],finePath.p[1]);
             initialized = true;
          }else
          {
             mainMap.newTiles = 0;
             mainMap.newTilesR = 0;
          }
       }
    }

    function onTimerReset()
    {
       initialized=false;
    }
    
    
    function onTimerStop()
    {
       lastPauseClick = System.getTimer();
    }
    
    function onTimerStart()
    {
    	if(  System.getTimer() - lastPauseClick < 500) {
    	 zoomMode = !zoomMode;
    	 redoLayout = true;
    	}
       
       
    }
    
	(:fenix6)
    function onLayout(dc)
    {
    	var mySettings = System.getDeviceSettings();
		var sWidth = mySettings.screenWidth;
		var sHeight = mySettings.screenHeight;
       displaySizeX=dc.getWidth();
       displaySizeY=dc.getHeight();
       displayMiddleX = displaySizeX>>1;
       displayMiddleY = displaySizeY>>1;
       if (displaySizeX != sWidth || displaySizeY != sHeight)
       {
          singleDataField = false;
       }else
       {
          singleDataField = true;
       }
       if(!zoomMode) {
       	   tileWidth = sWidth/5;
	       tileHeight = sHeight/5;
	       standardTileHeight = tileHeight;
	       tx=[ 0, tileWidth*1, tileWidth*2, tileWidth*3, tileWidth*4, tileWidth*5+1];
	       ty=[ 0, tileWidth*1, tileWidth*2, tileWidth*3, tileWidth*4, tileWidth*5+1];
       } else {
       		tileWidth = sWidth/2;
	       tileHeight = sHeight/2;
	       tx=[ 0, 0, tileWidth/2, tileWidth*1.5, sWidth, sWidth];
	       ty=[ 0, 0, tileWidth/2, tileWidth*1.5, sWidth, sWidth];
       }
       
       
       return true;
    }


    (:ed520)
    function onLayout(dc)
    {
       // hard coded for devices with 200x265
       displaySizeX=dc.getWidth();
       displaySizeY=dc.getHeight();
       displayMiddleX = displaySizeX>>1;
       displayMiddleY = displaySizeY>>1;
       if (displaySizeX != 200 || displaySizeY != 265)
       {
          singleDataField = false;
       }else
       {
          singleDataField = true;
       }
       tx=[ 0, 25,  75, 125, 175, 201];
       ty=[40, 65, 115, 165, 215, 266];
       tileWidth=50;
       tileHeight=50;

       return true;
    }

    (:ed530)
    function onLayout(dc)
    {
       displaySizeX=dc.getWidth();
       displaySizeY=dc.getHeight();
       displayMiddleX = displaySizeX>>1;
       displayMiddleY = displaySizeY>>1;
       if(displaySizeX>displaySizeY)
       {
          // hard coded for devices with 322x246
          if (displaySizeX != 322 || displaySizeY != 246)
          {
             singleDataField = false;
          }else
          {
             singleDataField = true;
          }
          tx=[ 72, 122,  172, 222, 272, 323];
          ty=[0, 48, 98, 148, 198, 247];
          tileWidth=50;
          tileHeight=50;
          landscapeMode = true;
       }else
       {
          // hard coded for devices with 246x322
          if (displaySizeX != 246 || displaySizeY != 322)
          {
             singleDataField = false;
          }else
          {
             singleDataField = true;
          }
          tx=[ 0, 48,  98, 148, 198, 247];
          ty=[72, 122, 172, 222, 272, 323];
          tileWidth=50;
          tileHeight=50;
          landscapeMode = false;
       }
       return true;
    }


    (:ed1000)
    function onLayout(dc)
    {
       displaySizeX=dc.getWidth();
       displaySizeY=dc.getHeight();
       displayMiddleX = displaySizeX>>1;
       displayMiddleY = displaySizeY>>1;
       if(displaySizeX>displaySizeY)
       {
          // hard coded for devices with 400x240
          if (displaySizeX != 400 || displaySizeY != 240)
          {
             singleDataField = false;
          }else
          {
             singleDataField = true;
          }
          tx=[ 100, 160,  220, 280, 340, 401];
          ty=[0, 30, 90, 150, 210, 241];
          tileWidth=60;
          tileHeight=60;
          landscapeMode = true;
       }else
       {
          // hard coded for devices with 240x400
          if (displaySizeX != 240 || displaySizeY != 400)
          {
             singleDataField = false;
          }else
          {
             singleDataField = true;
          }
          tx=[ 0, 30,  90, 150, 210, 241];
          ty=[100, 160, 220, 280, 340, 401];
          tileWidth=60;
          tileHeight=60;
          landscapeMode = false;
       }
       return true;
    }

    (:ed1030)
    function onLayout(dc)
    {
       displaySizeX=dc.getWidth();
       displaySizeY=dc.getHeight();
       displayMiddleX = displaySizeX>>1;
       displayMiddleY = displaySizeY>>1;
       if(displaySizeX>displaySizeY)
       {
          // hard coded for devices with 470x282
          if (displaySizeX != 470 || displaySizeY != 282)
          {
             singleDataField = false;
          }else
          {
             singleDataField = true;
          }
          tx=[ 110, 182,  254, 326, 398, 471];
          ty=[ 0, 33,  105, 177, 249, 283];
          tileWidth=72;
          tileHeight=72;
       }else
       {
          // hard coded for devices with 282x470
          if (displaySizeX != 282 || displaySizeY != 470)
          {
             singleDataField = false;
          }else
          {
             singleDataField = true;
          }
          tx=[ 0, 33,  105, 177, 249, 283];
          ty=[110, 182, 254, 326, 398, 471];
          tileWidth=72;
          tileHeight=72;
          landscapeMode = false;
       }

       return true;
    }

    // The given info object contains all the current workout information.
    // Calculate a value and save it locally in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info)
    {
       if( info != null)
       {
          heading = info.currentHeading;
          if(heading==null)
          {
             heading = 0.0;
          }

          if (info.currentLocation != null)
          {
             var ddgr = info.currentLocation.toDegrees();
             var dgr = [ddgr[0].toFloat(), ddgr[1].toFloat()];
             var i= 0;
             if(!initialized)
             {
                finePath.set(0,dgr);
                //coarsePath.set(0,dgr);
                coarsePath.l=-1;
                mainMap.newTiles = 0;
                mainMap.newTilesR= 0;
                initialized=true;
                mainMap.loni = mainMap.totalTiles + 1; // to force a map update
             }

             if( mainMap.isDistanceBiggerThanPixel(dgr,finePath.getDeg(null), tileWidth, tileHeight) )
             {
                finePath.add(dgr);
             }
             if( mainMap.setMap(dgr[1],dgr[0]) )
             {
                coarsePath.add(dgr);
                mainMap.setTiles(coarsePath.p,coarsePath.l);
                coarsePath.save();
                //Storage.setValue eats mem like crazy, free some up before saving...
                coarsePath.p = null;
                finePath.p = null;
                mainMap.save();
                coarsePath.load();
                finePath.p = new[100];
                finePath.set(0,dgr);
             }
          }
       }
    }


    function fgbgCol(dc, col1, col2)
    {
       if(getBackgroundColor()==Gfx.COLOR_BLACK)
       {
          dc.setColor(col1,Gfx.COLOR_BLACK);
       }else
       {
          dc.setColor(col2,Gfx.COLOR_WHITE);
       }
    }

    function setCol(dc,v)
    {
      if(v==0)
      {
         dc.setColor(Gfx.COLOR_DK_RED, Gfx.COLOR_DK_RED);
      }
      if(v==1)
      {
         dc.setColor(Gfx.COLOR_DK_GREEN, Gfx.COLOR_DK_GREEN);
      }
      if(v==2)
      {
         dc.setColor(Gfx.COLOR_GREEN, Gfx.COLOR_GREEN);
      }
    }

//    function setCol(dc,v)
//    {
//      if(v==0)
//      {
//         dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_LT_GRAY);
//      }
//      if(v==1)
//      {
//         dc.setColor(Gfx.COLOR_PURPLE, Gfx.COLOR_PURPLE);
//      }
//      if(v==2)
//      {
//         dc.setColor(Gfx.COLOR_PINK, Gfx.COLOR_PINK);
//      }
//    }


    function plotArrow(dc,x,y)
    {
       // rotate and translate
       var c =  Math.cos(heading);
       var s = -Math.sin(heading);
       var x2= Math.round( c*(-6) +s*(20.0)).toNumber() + x;
       var y2= Math.round(-s*(-6) +c*(20.0)).toNumber() + y;
       var x3= Math.round(        +s*(15.0)).toNumber() + x;
       var y3= Math.round(        +c*(15.0)).toNumber() + y;
       var x4= Math.round( c*( 6) +s*(20.0)).toNumber() + x;
       var y4= Math.round(-s*( 6) +c*(20.0)).toNumber() + y;

       fgbgCol(dc,Gfx.COLOR_DK_BLUE,Gfx.COLOR_BLUE);
       dc.fillPolygon([[x,y],[x2,y2],[x3,y3],[x4,y4],[x,y]]);
       fgbgCol(dc,Gfx.COLOR_BLUE,Gfx.COLOR_DK_BLUE);
       dc.drawLine(x,y,x2,y2);
       dc.drawLine(x2,y2,x3,y3);
       dc.drawLine(x3,y3,x4,y4);
       dc.drawLine(x4,y4,x,y);
    }


    (:header)
    function header(dc)
    {
       dc.setClip(tx[0],0,displaySizeX,ty[0]);

       dc.drawText(displayMiddleX, ty[0]/4, Gfx.FONT_SMALL,
              "new: "+mainMap.newTiles.format("%i")+", tot: "+mainMap.newTilesR.format("%i")+", pos: ["+(mainMap.loni-mainMap.hloni).format("%i")+"/"+(mainMap.lati-mainMap.hlati).format("%i")+"]",
              Gfx.TEXT_JUSTIFY_CENTER);

       dc.setClip(tx[0],ty[0],displaySizeX,displaySizeY-ty[0]);
    }
    
    
    (:headerC)
    function header(dc)
    {
       dc.setClip(0,0,displaySizeX,standardTileHeight/2);

       dc.drawText(displayMiddleX,standardTileHeight/2-dc.getFontHeight(Gfx.FONT_SYSTEM_XTINY) , Gfx.FONT_SYSTEM_XTINY,
              "n: "+mainMap.newTiles.format("%i")+", t: "+mainMap.newTilesR.format("%i"),
              Gfx.TEXT_JUSTIFY_CENTER);
              
       dc.setClip(0,displaySizeY-standardTileHeight/2,displaySizeX,displaySizeY);
              
       dc.drawText(displayMiddleX, displaySizeY-standardTileHeight/2, Gfx.FONT_SYSTEM_XTINY,
              "["+(mainMap.loni-mainMap.hloni).format("%i")+"/"+(mainMap.lati-mainMap.hlati).format("%i")+"]",
              Gfx.TEXT_JUSTIFY_CENTER);
              
       dc.setClip(0,standardTileHeight / 2,displaySizeX,standardTileHeight * 4);
    }

    (:headerV)
    function header(dc)
    {
       if(landscapeMode==true)
       {
           dc.setClip(0,0,tx[0],displaySizeY);
           dc.drawText(tx[0]/2, displaySizeY/4-16, Gfx.FONT_TINY, "new tiles",Gfx.TEXT_JUSTIFY_CENTER);
           dc.drawText(tx[0]/2, displaySizeY/4, Gfx.FONT_MEDIUM,
              mainMap.newTiles.format("%i"),Gfx.TEXT_JUSTIFY_CENTER);
           dc.drawText(tx[0]/2, displaySizeY/2-16, Gfx.FONT_TINY, "tiles crossed",Gfx.TEXT_JUSTIFY_CENTER);
           dc.drawText(tx[0]/2, displaySizeY/2, Gfx.FONT_MEDIUM,
              mainMap.newTilesR.format("%i"),Gfx.TEXT_JUSTIFY_CENTER);
           dc.drawText(tx[0]/2, 3*displaySizeY/4-16, Gfx.FONT_TINY, "current pos.",Gfx.TEXT_JUSTIFY_CENTER);
           dc.drawText(tx[0]/2,3*displaySizeY/4, Gfx.FONT_MEDIUM,
             "["+(mainMap.loni-mainMap.hloni).format("%i")+"/"+(mainMap.lati-mainMap.hlati).format("%i")+"]",Gfx.TEXT_JUSTIFY_CENTER);

           dc.setClip(tx[0],0,displaySizeX-tx[0],displaySizeY);
        }else
        {
           dc.setClip(tx[0],0,displaySizeX,ty[0]);

           dc.drawText(displayMiddleX, 1, Gfx.FONT_MEDIUM,
              "new tiles: "+mainMap.newTiles.format("%i"),Gfx.TEXT_JUSTIFY_CENTER);
           dc.drawText(displayMiddleX, ty[0]/3, Gfx.FONT_MEDIUM,
              "tiles crossed: "+mainMap.newTilesR.format("%i"),Gfx.TEXT_JUSTIFY_CENTER);
           dc.drawText(displayMiddleX, 2*ty[0]/3, Gfx.FONT_MEDIUM,
              "current pos.: ["+(mainMap.loni-mainMap.hloni).format("%i")+"/"+(mainMap.lati-mainMap.hlati).format("%i")+"]",
              Gfx.TEXT_JUSTIFY_CENTER);

           dc.setClip(tx[0],ty[0],displaySizeX,displaySizeY-ty[0]);
        }
    }

    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
    function onUpdate(dc) {
    
    	if(redoLayout) {
    		onLayout(dc);
    		redoLayout = false;
    	}
    	
        fgbgCol(dc,Gfx.COLOR_WHITE,Gfx.COLOR_BLACK);

        //this data field works only in 1-datafield layout
        if(singleDataField==true)
        {
           var lx=0;
           var ly=0;
           var i=0;

           header(dc);

           // draw 5x5 tiles
           for(ly=0;ly<5;ly++)
           {
              for(lx=0;lx<5;lx++)
              {
                 setCol(dc,mainMap.ltiles[lx+5*ly]);
                 dc.fillRectangle(tx[lx], ty[ly], tx[lx+1]-tx[lx]-1, ty[ly+1]-ty[ly]-1);
              }
           }

           var px = mainMap.deg2px([mainMap.clat,mainMap.clon], tileWidth, tileHeight);
           plotArrow(dc,px[0]+tx[2],px[1]+ty[2]);

           // fine grained path
           dc.setPenWidth(2);
           fgbgCol(dc,Gfx.COLOR_DK_GRAY,Gfx.COLOR_BLACK);

           lx=px[0];
           ly=px[1];
           for(i=finePath.l-1; i>=0; i--)
           {
              px = mainMap.deg2px(finePath.getDeg(i), tileWidth, tileHeight);
              dc.drawLine(lx+tx[2],ly+ty[2],px[0]+tx[2],px[1]+ty[2]);
              lx=px[0];
              ly=px[1];
           }


           // coarse grained path
           fgbgCol(dc,Gfx.COLOR_DK_GRAY,Gfx.COLOR_DK_GRAY);

           for(i=coarsePath.l; i>=0; i--)
           {
              px = mainMap.deg2px(coarsePath.getDeg(i), tileWidth, tileHeight);
              dc.drawLine(lx+tx[2],ly+ty[2],px[0]+tx[2],px[1]+ty[2]);
              lx=px[0];
              ly=px[1];
           }
           dc.setPenWidth(1);
         }else
         {
            dc.setClip(0,0,displaySizeX,displaySizeY);
            dc.drawText(displaySizeX/2,5,Gfx.FONT_MEDIUM,Ui.loadResource(Rez.Strings.wholeDisp),Gfx.TEXT_JUSTIFY_CENTER);
         }

    }

}
