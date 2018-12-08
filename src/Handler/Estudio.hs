{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE QuasiQuotes #-}
module Handler.Estudio where

import Import
import Text.Lucius
import Text.Julius
import Prelude (read)

widgetNav :: Maybe Text -> Widget
widgetNav logado = $(whamletFile "templates/navbar.hamlet")

widgetFooter :: Widget
widgetFooter = $(whamletFile "templates/footer.hamlet")

getEstudioR :: Handler Html
getEstudioR = do 
    logado <- lookupSession "_USR"
    defaultLayout $ do 
        setTitle "Estúdio de Criação - AvataR"
        toWidgetHead [hamlet|
            <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" charset="utf-8">
            <script src=@{StaticR js_jquery_js}>
            <script src=@{StaticR js_bootstrap_js}>
        |]
        addStylesheet $ StaticR css_bootstrap_css
        $(whamletFile "templates/estudio.hamlet")
        toWidget $(luciusFile "templates/estilocomp.lucius")
        toWidgetBody $(juliusFile "templates/scriptcomp.julius")
        