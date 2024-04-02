{-# LANGUAGE BlockArguments #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}

module Main where

import Control.Monad (unless, void, when)
import Data.Aeson.TH (defaultOptions, deriveJSON, fieldLabelModifier, omitNothingFields)
import Data.Either (isLeft, lefts, rights)
import Data.List (isPrefixOf, isSuffixOf)
import Data.Map (Map, toList)
import Data.Maybe (fromMaybe, mapMaybe)
import Data.Text (Text, pack, replace, toLower, unpack)
import Data.Void (Void)
import Data.Yaml (ParseException, decodeFileEither)
import System.Environment (getEnvironment)
import System.Exit (exitSuccess)
import Text.Megaparsec (Parsec, anySingle, errorBundlePretty, manyTill, optional, parse, parseMaybe, skipManyTill)
import Text.Megaparsec.Char (char, string)
import Text.Pretty.Simple (pPrint)

-- CONFIG

data Config
    = Config
    { readmeFile :: String
    , debug :: Bool
    }
    deriving (Show)

getConfig :: IO Config
getConfig = do
    env <- getEnvironment
    let readmeFile' = fromMaybe "README.md" $ lookup "README_FILE" env
    let debug' = (Just "false" ==) $ lookup "DEBUG" env
    return $ Config readmeFile' debug'

-- ACTIONS

data ActionInput
    = ActionInput
    { type' :: Maybe String
    , description :: Maybe String
    , required :: Maybe Bool
    , default' :: Maybe String
    }
    deriving (Show)

$(deriveJSON defaultOptions{omitNothingFields = True, fieldLabelModifier = filter (/= '\'')} ''ActionInput)

data Action
    = Action
    { name :: String
    , description :: String
    , inputs :: Map String ActionInput
    }
    deriving (Show)

$(deriveJSON defaultOptions{omitNothingFields = True, fieldLabelModifier = filter (/= '\'')} ''Action)

data ActionMetadata
    = ActionMetadata
    { path :: String
    , owner :: Maybe String
    , project :: Maybe String
    , version :: Maybe String
    }
    deriving (Show, Eq)

toEnglishBool :: Bool -> String
toEnglishBool True = "yes"
toEnglishBool False = "no"

actionStartTagPrefix :: String
actionStartTagPrefix = "<!-- gh-actions-docs-start"

actionEndTag :: String
actionEndTag = "<!-- gh-actions-docs-end -->"

tocStartTag :: String
tocStartTag = "<!-- gh-actions-docs-toc-start -->"

tocEndTag :: String
tocEndTag = "<!-- gh-actions-docs-toc-end -->"

prettyPrintAction :: Action -> ActionMetadata -> String
prettyPrintAction (Action name' description' inputs') actionMetadata =
    "## "
        ++ name'
        ++ "\n\n"
        ++ "### Description\n"
        ++ description'
        ++ "\n\n"
        ++ "### Inputs\n"
        ++ prettyPrintInputs inputs'
        ++ maybe "" ("### Usage\n" ++) (prettyPrintUsage inputs' actionMetadata)

prettyPrintInputs :: Map String ActionInput -> String
prettyPrintInputs inputs' =
    "|Name|Type|Description|Required|Default|\n"
        ++ "|-|-|-|-|-|\n"
        ++ concatMap
            ( \(name', ActionInput typ des req def) ->
                name' ++ "|" ++ fromMaybe "" typ ++ "|" ++ fromMaybe "" des ++ "|" ++ maybe "no" toEnglishBool req ++ "|" ++ fromMaybe "" def ++ "|\n"
            )
            (toList inputs')
        ++ "\n"

prettyPrintUsage :: Map String ActionInput -> ActionMetadata -> Maybe String
prettyPrintUsage inputs' (ActionMetadata _ (Just owner') (Just project') (Just version')) =
    Just $
        "```yaml\n"
            ++ "uses: "
            ++ owner'
            ++ "/"
            ++ project'
            ++ "@"
            ++ version'
            ++ "\n"
            ++ "with:\n"
            ++ concatMap (uncurry prettyPrintUsage') (toList inputs')
            ++ "```\n"
prettyPrintUsage _ _ = Nothing

prettyPrintUsage' :: String -> ActionInput -> String
prettyPrintUsage' name' (ActionInput _ des req def) =
    indent
        ++ name'
        ++ ":\n"
        ++ ( case (des, req, def) of
                (Just des', Just req', Just def') ->
                    formatDescription des' ++ formatRequired req' ++ formatDefault def'
                (Just des', Just req', _) ->
                    formatDescription des' ++ formatRequired req'
                (Just des', _, Just def') ->
                    formatDescription des' ++ formatDefault def'
                (Just des', _, _) ->
                    formatDescription des'
                _ ->
                    ""
           )
  where
    indent = replicate 4 ' '
    formatDescription des' = indent ++ "# " ++ des' ++ "\n" ++ indent ++ "#\n"
    formatRequired req' = indent ++ "# Required: " ++ toEnglishBool req' ++ "\n"
    formatDefault def' = indent ++ "# Default: '" ++ def' ++ "'\n"

-- PARSERS

type Parser = Parsec Void Text

actionMetadataParser :: Parser ActionMetadata
actionMetadataParser = do
    _ <- string $ pack actionStartTagPrefix
    _ <- string " path="
    path' <- manyTill anySingle (char ' ')
    owner' <- optional $ do
        _ <- string "owner="
        manyTill anySingle (char ' ')
    project' <- optional $ do
        _ <- string "project="
        manyTill anySingle (char ' ')
    version' <- optional $ do
        _ <- string "version="
        manyTill anySingle (char ' ')
    _ <- string "-->"
    return $ ActionMetadata path' owner' project' version'

specificActionMetadataParser_ :: ActionMetadata -> Parser ()
specificActionMetadataParser_ =
    void . string . pack . actionMetadataToString

betweenActionTagParser :: Parser String
betweenActionTagParser = do
    meta <- skipManyTill anySingle actionMetadataParser
    between' <- manyTill anySingle $ string $ pack actionEndTag
    return $ actionMetadataToString meta ++ between' ++ actionEndTag

betweenSpecificActionTagParser :: ActionMetadata -> Parser String
betweenSpecificActionTagParser meta = do
    _ <- skipManyTill anySingle $ specificActionMetadataParser_ meta
    between' <- manyTill anySingle $ string $ pack actionEndTag
    return $ actionMetadataToString meta ++ between' ++ actionEndTag

betweenTableOfContentsTagParser :: Parser String
betweenTableOfContentsTagParser = do
    _ <- manyTill anySingle $ string $ pack tocStartTag
    between' <- manyTill anySingle $ string $ pack tocEndTag
    return $ tocStartTag ++ between' ++ tocEndTag

actionMetadataToString :: ActionMetadata -> String
actionMetadataToString (ActionMetadata path' owner' project' version') =
    actionStartTagPrefix
        ++ " path="
        ++ path'
        ++ maybe "" (" owner=" ++) owner'
        ++ maybe "" (" project=" ++) project'
        ++ maybe "" (" version=" ++) version'
        ++ " -->"

replaceActionTagWithDocs :: String -> (ActionMetadata, Action) -> String
replaceActionTagWithDocs readme (meta, action) =
    case parse (betweenSpecificActionTagParser meta) "" (pack readme) of
        Right match ->
            let docs = startTag ++ "\n" ++ prettyPrintAction action meta ++ actionEndTag
             in unpack $ replace (pack match) (pack docs) (pack readme)
        Left err ->
            error $ errorBundlePretty err
  where
    startTag = actionMetadataToString meta

replaceTableOfContentsTagWithTableOfContents :: String -> String -> String
replaceTableOfContentsTagWithTableOfContents toc readme =
    case parse betweenTableOfContentsTagParser "" (pack readme) of
        Right match ->
            let toc' = tocStartTag ++ "\n" ++ toc ++ tocEndTag
             in unpack $ replace (pack match) (pack toc') (pack readme)
        Left err ->
            error $ errorBundlePretty err

-- TABLE OF CONTENTS

processHeaderLines :: [String] -> [String] -> String
processHeaderLines (l : ls) skips =
    if any (`isSuffixOf` l) skips
        then processHeaderLines ls skips
        else case l of
            '#' : ' ' : l' ->
                padLevel 1 ++ enclose l' ++ processHeaderLines ls skips
            '#' : '#' : ' ' : l' ->
                padLevel 2 ++ enclose l' ++ processHeaderLines ls skips
            '#' : '#' : '#' : ' ' : l' ->
                padLevel 3 ++ enclose l' ++ processHeaderLines ls skips
            '#' : '#' : '#' : '#' : ' ' : l' ->
                padLevel 4 ++ enclose l' ++ processHeaderLines ls skips
            _ -> ""
  where
    slugify = unpack . toLower . replace " " "-" . pack
    enclose n = "- [" ++ n ++ "](#" ++ slugify n ++ ")\n"
    padLevel n = replicate (2 * (n - 1)) ' '
processHeaderLines [] _ = "\n"

-- MAIN

main :: IO ()
main = do
    config <- getConfig
    when (debug config) do
        putStrLn "Debug mode enabled"
        putStrLn "Config:"
        print config
    readme <- readFile $ readmeFile config

    let actionStartTagLines = filter (isPrefixOf actionStartTagPrefix) $ lines readme
    when (null actionStartTagLines) do
        putStrLn $ "No action tags found in " ++ readmeFile config ++ ", exiting..."
        exitSuccess
    when (debug config) do
        putStrLn $ "Action tags found in " ++ readmeFile config ++ ":"
        pPrint actionStartTagLines

    let actionMetadataList = mapMaybe (parseMaybe actionMetadataParser . pack) actionStartTagLines
    when (debug config) do
        putStrLn "Action metadata:"
        pPrint actionMetadataList

    parsedFiles <- mapM (decodeFileEither . path) actionMetadataList :: IO [Either ParseException Action]
    when (any isLeft parsedFiles) do
        let filesNotFound = lefts parsedFiles
        mapM_ (putStrLn . (("Error parsing file: " ++) . show)) filesNotFound
        pPrint filesNotFound

    let parsedFilesWithMetadata = zip actionMetadataList (rights parsedFiles)
    when (debug config) do
        putStrLn "Action results:"
        pPrint parsedFilesWithMetadata

    let newReadme = foldl replaceActionTagWithDocs readme parsedFilesWithMetadata
    unless (newReadme == readme) do
        writeFile "README.md" newReadme
        putStrLn $ readmeFile config ++ " updated successfully!"

    let headerLines = drop 1 $ filter (isPrefixOf "#") $ lines newReadme
    let toc = processHeaderLines headerLines ["Table of Contents"]
    when (debug config) do
        putStrLn "Table of contents:"
        putStrLn toc

    let newReadmeWithToc = replaceTableOfContentsTagWithTableOfContents toc newReadme
    unless (newReadmeWithToc == newReadme) do
        writeFile "README.md" newReadmeWithToc
        putStrLn $ readmeFile config ++ " updated successfully!"
