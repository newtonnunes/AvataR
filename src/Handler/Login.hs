{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE QuasiQuotes #-}
module Handler.Login where

import Import
import Text.Lucius
import Text.Julius
import Database.Persist.Sql
import Prelude (read)

widgetNav :: Maybe Text -> Widget
widgetNav logado = $(whamletFile "templates/navbar.hamlet")

widgetFooter :: Widget
widgetFooter = $(whamletFile "templates/footer.hamlet")

formLogin :: Form (Text, Text)
formLogin = renderBootstrap $ pure (,)
    <*> areq emailField "E-mail: " Nothing
    <*> areq passwordField "Password: " Nothing

getLoginR :: Handler Html
getLoginR = do 
    (widgetLogin, enctype) <- generateFormPost formLogin
    msg <- getMessage
    logado <- lookupSession "_USR"
    defaultLayout $ do 
        setTitle "Login AvataR"
        toWidgetHead [hamlet|
            <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
            <script src=@{StaticR js_jquery_js}>
            <script src=@{StaticR js_bootstrap_js}>
        |]
        addStylesheet $ StaticR css_bootstrap_css
        $(whamletFile "templates/login.hamlet")
        toWidget $(luciusFile "templates/estilo.lucius")
        toWidgetBody $(juliusFile "templates/script.julius")

postLoginR :: Handler Html
postLoginR = do 
    ((res,_),_) <- runFormPost formLogin
    case res of 
        FormSuccess (email,senha) -> do 
            usr <- runDB $ selectFirst [UsuarioEmail ==. email
                                       ,UsuarioSenha ==. senha] []
            case usr of 
                Just (Entity usrid usuario) -> do 
                    setSession "_USR" (pack (show usuario))
                    setMessage [shamlet|
                        #{usuarioNome usuario} logado com sucesso!
                    |]
                    redirect HomeR
                Nothing -> do 
                    setMessage [shamlet|
                        Usuário não encontrado.
                    |]
                    redirect LoginR
        _ -> redirect LoginR

postLogoutR :: Handler Html
postLogoutR = do 
    deleteSession "_USR"
    redirect HomeR