{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
module Handler.Home where

import Import
import Text.Lucius
import Text.Julius

widgetFooter :: Widget
widgetFooter = $(whamletFile "templates/footer.hamlet")

getHomeR :: Handler Html
getHomeR = do 
    msg <- getMessage
    sess <- lookupSession "_USR"
    defaultLayout $ do 
        addStylesheet $ StaticR css_bootstrap_css
        toWidgetHead $(juliusFile "templates/home.julius")
        toWidget $(luciusFile "templates/home.lucius")
        $(whamletFile "templates/home.hamlet")