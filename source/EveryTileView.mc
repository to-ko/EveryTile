using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Math as Math;
using Toybox.Activity as Act;
using Toybox.Application.Storage;

class EveryTileView extends Ui.DataField {

    const Pmax =  50; // pixels of track to store exactly
    const cPmax= 200; // tiles of track to store

    hidden var tileW = 50;
    hidden var tileH = 50;
    hidden var initialized = false;

    hidden var lp = 0;       // counter for the path
    hidden var clp= 0;       // counter for cpath;
    hidden var path = new[Pmax*2];
    hidden var cpath= new[cPmax*2];

    hidden var tx = new[6]; // coordinates of tiles on the screen
    hidden var ty = new[6];
    hidden var dx = 0;      // screen size
    hidden var dy = 0;
    hidden var heading = 0.0;
    hidden var mp;          // main map object


    function deg2px(dgr)
    {
       var px = [0, 0];
       px[0] = Math.floor((((dgr[1] + 180.0d) * 45.5111111111111d)-mp.loni) * tileW).toNumber();
       px[1] = Math.floor(((1.0 - Math.ln(Math.tan(dgr[0]*0.0174532925199433d) + (1.0 / Math.cos(dgr[0]*0.0174532925199433d))) * 0.318309886183791d) *8192-mp.lati)*tileH).toNumber();
       return px;
    }

    function pxdist(dgr1,dgr2)
    {
       if (  (   ((dgr1[1]-dgr2[1]) * 45.5111111111111d * tileW ).abs().toNumber()>1 ) ||
             (   ( (- Math.ln(Math.tan(dgr1[0]*0.0174532925199433d) + (1.0 / Math.cos(dgr1[0]*0.0174532925199433d)))
                    + Math.ln(Math.tan(dgr2[0]*0.0174532925199433d) + (1.0 / Math.cos(dgr2[0]*0.0174532925199433d))) ) * 0.318309886183791d *8192*tileH
                 ).abs().toNumber()>1))
       {
          return true;
       }else
       {
          return false;
       }
    }


    function initialize()
    {
       DataField.initialize();
       mp = new map();

       lp = 0;
       path[0] = mp.hlon;
       path[1] = mp.hlat;
       clp=0;
       cpath[0] = mp.hlon;
       cpath[1] = mp.hlat;
       initialized=false;

       var inf = Act.getActivityInfo();
       if( (inf!=null) && (inf.elapsedTime > 10000) )
       {
          // attempt to continue activity
          cpath=Storage.getValue("cpath");
          clp=Storage.getValue("clp");
          mp.newTiles=Storage.getValue("newTiles");
          mp.newTilesR=Storage.getValue("newTilesR");
          if((clp!=null) && (cpath!=null) && (mp.newTiles)!=null || ( mp.newTilesR!=null ))
          {
             lp = 0;
             path[0] = cpath[2*clp];
             path[1] = cpath[2*clp+1];
             mp.setMap(path[0],path[1]);
             initialized = true;
          }else
          {
             mp.newTiles = 0;
             mp.newTilesR = 0;
             cpath = new[cPmax*2];
             cpath[0] = mp.hlon;
             cpath[1] = mp.hlat;
             clp=0;
          }
       }
    }


    // Set your layout here. Anytime the size of obscurity of
    // the draw context is changed this will be called.
    function onLayout(dc)
    {
       dx = dc.getWidth();
       dy = dc.getHeight();

       tx = [0, dx/8, 3*dx/8, 5*dx/8, dx-dx/8, dx+1];
       ty = [40, 40+dx/8, 40+3*dx/8, 40+5*dx/8, 40+7*dx/8, dy+1];
       tileW = dx/4;
       tileH = dx/4;

       return true;
    }



    // The given info object contains all the current workout information.
    // Calculate a value and save it locally in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info)
    {
       if( (info != null) && (info.currentLocation != null))
       {
          var ddgr = info.currentLocation.toDegrees();
          var dgr = [ddgr[0].toFloat(), ddgr[1].toFloat()];
          var i= 0;
          heading = info.currentHeading;
          if(!initialized)
          {
             lp = 0;
             path[0] = dgr[1];
             path[1] = dgr[0];
             clp = 0;
             cpath[0] = dgr[1];
             cpath[1] = dgr[0];
             initialized=true;
             mp.setMap(dgr[1],dgr[0]);
             mp.setTiles(cpath,clp);
          }else
          {
             if( pxdist(dgr,[path[2*lp+1],path[2*lp]]) )
             {
                //add new pixel to path
                lp = lp+1;
                if (lp==Pmax)
                {
                   // path to long for memory, throw away oldest half
                   for (i=0; i<Pmax; i++)
                   {
                      path[i] = path[i+Pmax];
                   }
                   lp = Pmax/2;
                }
                path[2*lp]   = dgr[1];
                path[2*lp+1] = dgr[0];
             }
             if( mp.setMap(dgr[1],dgr[0]) )
             {
                clp++;
                if (clp==cPmax)
                {
                   // path to long for memory, throw away oldest half, tilesR may become inaccurate
                   for (i=0; i<cPmax; i++)
                   {
                      cpath[i] = cpath[i+cPmax];
                   }
                   clp = cPmax/2;
                }
                cpath[2*clp]   = dgr[1];
                cpath[2*clp+1] = dgr[0];
                path[0] = dgr[1];
                path[1] = dgr[0];
                lp=0;
                mp.setTiles(cpath,clp);
                Storage.setValue("cpath",cpath);
                Storage.setValue("clp",clp);
                mp.save();
             }
          }
       }
    }




    function setCol(dc,v)
    {
       if(getBackgroundColor()==Gfx.COLOR_BLACK)
       {
          switch(v){
             case 0:
                dc.setColor(Gfx.COLOR_DK_RED, Gfx.COLOR_DK_RED);
                break;
             case 1:
                dc.setColor(Gfx.COLOR_DK_GREEN, Gfx.COLOR_DK_GREEN);
                break;
             case 2:
                dc.setColor(Gfx.COLOR_GREEN, Gfx.COLOR_GREEN);
                break;
          }
       }else
       {
          switch(v){
             case 0:
                dc.setColor(Gfx.COLOR_DK_RED, Gfx.COLOR_DK_RED);
                break;
             case 1:
                dc.setColor(Gfx.COLOR_DK_GREEN, Gfx.COLOR_DK_GREEN);
                break;
             case 2:
                dc.setColor(Gfx.COLOR_GREEN, Gfx.COLOR_GREEN);
                break;
          }
       }
    }


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

       if(getBackgroundColor() == Gfx.COLOR_BLACK)
       {
          dc.setColor(Gfx.COLOR_DK_BLUE, Gfx.COLOR_BLACK);
       }else
       {
          dc.setColor(Gfx.COLOR_BLUE,Gfx.COLOR_WHITE);
       }
       dc.fillPolygon([[x,y],[x2,y2],[x3,y3],[x4,y4],[x,y]]);
       if(getBackgroundColor() == Gfx.COLOR_BLACK)
       {
          dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_BLACK);
       }else
       {
          dc.setColor(Gfx.COLOR_DK_BLUE,Gfx.COLOR_WHITE);
       }
       dc.drawLine(x,y,x2,y2);
       dc.drawLine(x2,y2,x3,y3);
       dc.drawLine(x3,y3,x4,y4);
       dc.drawLine(x4,y4,x,y);
    }


    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
    function onUpdate(dc) {

        if(getBackgroundColor() == Gfx.COLOR_BLACK)
        {
           dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
        }else
        {
           dc.setColor(Gfx.COLOR_BLACK,Gfx.COLOR_WHITE);
        }

        //this data field works only in 1-datafield layout
        if((dx>=200) & (dy>=265))
        {
           var mx = dx/2;
           var my = dy/2;
           var lx=0;
           var ly=0;

           // header line
           dc.setClip(tx[0],0,dx,ty[0]);
           var str = mp.newTiles.format("%i")+","+mp.newTilesR.format("%i")+",["+(mp.loni-mp.hloni).format("%i")+"/"+(mp.lati-mp.hlati).format("%i")+"]";
           dc.drawText(mx, ty[0]/4, Gfx.FONT_MEDIUM, str, Gfx.TEXT_JUSTIFY_CENTER);

           dc.setClip(tx[0],ty[0],dx,dy-ty[0]);
           // draw 5x5 tiles
           for(ly=0;ly<5;ly++)
           {
              for(lx=0;lx<5;lx++)
              {
                 setCol(dc,mp.ltiles[lx][ly]);
                 dc.fillRectangle(tx[lx], ty[ly], tx[lx+1]-tx[lx]-1, ty[ly+1]-ty[ly]-1);
              }
           }

           var px = deg2px([mp.clat,mp.clon]);
           plotArrow(dc,px[0]+tx[2],px[1]+ty[2]);



           // fine grained path
           dc.setPenWidth(2);
           if(getBackgroundColor() == Gfx.COLOR_BLACK)
           {
              dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
           }else
           {
              dc.setColor(Gfx.COLOR_BLACK,Gfx.COLOR_WHITE);
           }

           var i;

           lx=px[0];
           ly=px[1];
           for(i=lp-1; i>=0; i--)
           {
              px = deg2px([path[2*i+1],path[2*i]]);
              dc.drawLine(lx+tx[2],ly+ty[2],px[0]+tx[2],px[1]+ty[2]);
              lx=px[0];
              ly=px[1];
           }


           // coarse grained path
           if(getBackgroundColor() == Gfx.COLOR_BLACK)
           {
              dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_BLACK);
           }else
           {
              dc.setColor(Gfx.COLOR_DK_GRAY,Gfx.COLOR_WHITE);
           }

           for(i=clp; i>=0; i--)
           {
              px = deg2px([cpath[2*i+1],cpath[2*i]]);
              dc.drawLine(lx+tx[2],ly+ty[2],px[0]+tx[2],px[1]+ty[2]);
              lx=px[0];
              ly=px[1];
           }
           dc.setPenWidth(1);
         }else
         {
            dc.drawText(dc.getWidth()/2,5,Gfx.FONT_MEDIUM,"needs whole disp.",Gfx.TEXT_JUSTIFY_CENTER);
         }

    }

}
