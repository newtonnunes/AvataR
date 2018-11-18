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

formCadastro :: Form (Usuario, Text)
formCadastro = renderBootstrap $  pure (,)
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
    defaultLayout $ do 
        addStylesheet $ StaticR css_bootstrap_css
        $(whamletFile "templates/cadastro.hamlet")

postCadastroR :: Handler Html
postCadastroR = do 
    ((res,_),_) <- runFormPost formCadastro
    case res of
        FormSuccess (usr, passwordC) -> do 
            if (usuarioSenha usr) == passwordC then do
                runDB $ insert usr 
                setMessage [shamlet|
                    <h1>
                        Usuario cadastrado!
                |]
                redirect HomeR
            else do 
                setMessage [shamlet|
                    <h1>
                        Senhas não conferem
                |]
                redirect CadastroR
        _ -> redirect CadastroR