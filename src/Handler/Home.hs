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
widgetNav logado = $(whamletFile "templates/navbar.hamlet")

widgetFooter :: Widget
widgetFooter = $(whamletFile "templates/footer.hamlet")

getHomeR :: Handler Html
getHomeR = do 
    msg <- getMessage
    logado <- lookupSession "_USR"
    defaultLayout $ do 
        setTitle "AvataR"
        toWidgetHead [hamlet|
            <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" charset="utf-8">
            <script src=@{StaticR js_jquery_js}>
            <script src=@{StaticR js_bootstrap_js}>
        |]
        addStylesheet $ StaticR css_bootstrap_css
        $(whamletFile "templates/home.hamlet")
        toWidget $(luciusFile "templates/estilo.lucius")
        toWidgetBody $(juliusFile "templates/script.julius")
        
        