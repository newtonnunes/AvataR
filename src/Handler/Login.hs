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

widgetNav :: Widget
widgetNav = $(whamletFile "templates/navbar.hamlet")

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
    defaultLayout $ do 
        addStylesheet $ StaticR css_bootstrap_css
        $(whamletFile "templates/login.hamlet")

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
                        <h1>
                            #{usuarioNome usuario} logado com sucesso!
                    |]
                    redirect HomeR
                Nothing -> do 
                    setMessage [shamlet|
                        <h1>
                            Usuário não encontrado
                    |]
                    redirect LoginR
        _ -> redirect LoginR

postLogoutR :: Handler Html
postLogoutR = do 
    deleteSession "_USR"
    redirect HomeR