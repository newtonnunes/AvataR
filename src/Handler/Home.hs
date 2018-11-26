{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE QuasiQuotes #-}
module Handler.Home where

import Import
import Text.Lucius
import Text.Julius
import Prelude (read)
            
widgetNav :: Maybe Text -> Widget
widgetNav sess = $(whamletFile "templates/navbar.hamlet")

widgetFooter :: Widget
widgetFooter = $(whamletFile "templates/footer.hamlet")

getHomeR :: Handler Html
getHomeR = do 
    msg <- getMessage
    sess <- lookupSession "_USR"
    defaultLayout $ do 
        setTitle "AvataR"
        toWidgetHead [hamlet|
            <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
            <script src=@{StaticR js_bootstrap_js}>
            <script src=@{StaticR js_jquery_js}>
        |]
        addStylesheet $ StaticR css_bootstrap_css
        toWidget $(luciusFile "templates/estilo.lucius")
        toWidgetHead $(juliusFile "templates/script.julius")
        $(whamletFile "templates/home.hamlet")
        