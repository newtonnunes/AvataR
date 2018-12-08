{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE QuasiQuotes #-}
module Handler.Cadastro where

import Import
import Text.Lucius
import Text.Julius
import Database.Persist.Sql
import Control.Monad.Zip
import Prelude (read)

widgetNav :: Maybe Text -> Widget
widgetNav logado = $(whamletFile "templates/navbar.hamlet")

widgetFooter :: Widget
widgetFooter = $(whamletFile "templates/footer.hamlet")

formCadastro :: Form (Usuario, Text)
formCadastro = renderBootstrap $ pure (,)
    <*> (Usuario 
            <$> areq textField "Name" Nothing
            <*> areq emailField "E-mail" Nothing 
            <*> areq passwordField "Password" Nothing
    )
    <*> areq passwordField "Password confirm" Nothing

getCadastroR :: Handler Html
getCadastroR = do 
    (widgetCad, enctype) <- generateFormPost formCadastro
    msg <- getMessage
    logado <- lookupSession "_USR"
    defaultLayout $ do 
        setTitle "Cadastro AvataR"
        toWidgetHead [hamlet|
            <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
            <script src=@{StaticR js_jquery_js}>
            <script src=@{StaticR js_bootstrap_js}>
        |]
        addStylesheet $ StaticR css_bootstrap_css
        $(whamletFile "templates/cadastro.hamlet")
        toWidget $(luciusFile "templates/estilo.lucius")
        toWidgetBody $(juliusFile "templates/script.julius")

postCadastroR :: Handler Html
postCadastroR = do 
    ((res,_),_) <- runFormPost formCadastro
    case res of
        FormSuccess (usr, passwordC) -> do 
            if (usuarioSenha usr) == passwordC then do
                runDB $ insert usr 
                setMessage [shamlet|
                        Usuario cadastrado!
                |]
                redirect HomeR
            else do 
                setMessage [shamlet|
                        Senhas não conferem.
                |]
                redirect CadastroR
        _ -> redirect CadastroR