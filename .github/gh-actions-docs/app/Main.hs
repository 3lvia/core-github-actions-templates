{-# LANGUAGE BlockArguments        #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE TemplateHaskell       #-}

module Main where

import           Control.Monad        (void, when)
import           Data.Aeson.TH        (defaultOptions, deriveJSON,
                                       fieldLabelModifier, omitNothingFields)
import           Data.Either          (fromRight, isLeft, lefts, rights)
import           Data.List            (intercalate)
import           Data.List.Split      (splitOn)
import           Data.Map             (Map, fromList, toList)
import           Data.Maybe           (fromMaybe)
import           Data.Text            (Text, isPrefixOf, pack, replace, toLower,
                                       unpack)
import           Data.Void            (Void)
import           Data.Yaml            (ParseException, decodeFileEither)
import           System.Environment   (getEnvironment)
import           System.Exit          (exitFailure)
import           System.Process       (callCommand)
import           Text.Megaparsec      (Parsec, anySingle, eof,
                                       errorBundlePretty, many, manyTill,
                                       manyTill_, optional, parse, sepBy,
                                       skipManyTill, some, try, (<|>))
import           Text.Megaparsec.Char (char, latin1Char, newline, string)
import           Text.Pretty.Simple   (pPrint)

-- CONFIG

data Config
    = Config
    { readmeFile    :: String
    , debug         :: Bool
    , ignoreHeaders :: [String]
    , ignoreFiles   :: [String]
    , runPrettier   :: Bool
    , noActions     :: Bool
    , noToc         :: Bool
    , noName        :: Bool
    , noDescription :: Bool
    , noInputs      :: Bool
    , noPermissions :: Bool
    , noUsage       :: Bool
    }
    deriving (Show)

getConfig :: IO Config
getConfig = do
    env <- getEnvironment
    let readmeFile' = fromMaybe "README.md" $ lookup "README_FILE" env
    let debug' = lookup "DEBUG" env == Just "true"
    let ignoreHeaders' = maybe [] (splitOn ",") $ lookup "IGNORE_HEADERS" env
    let ignoreFiles' = maybe [] (splitOn ",") $ lookup "IGNORE_FILES" env
    let runPrettier' = lookup "RUN_PRETTIER" env == Just "true"
    let noActions' = lookup "NO_ACTIONS" env == Just "true"
    let noToc' = lookup "NO_TOC" env == Just "true"
    let noName' = lookup "NO_NAME" env == Just "true"
    let noDescription' = lookup "NO_DESCRIPTION" env == Just "true"
    let noInputs' = lookup "NO_INPUTS" env == Just "true"
    let noPermissions' = lookup "NO_PERMISSIONS" env == Just "true"
    let noUsage' = lookup "NO_USAGE" env == Just "true"
    when (noToc' && noActions') do
        putStrLn "Both NO_TOC and NO_ACTIONS are set to true, nothing to do."
        exitFailure
    return $ Config
                readmeFile'
                debug'
                ignoreHeaders'
                ignoreFiles'
                runPrettier'
                noActions'
                noToc'
                noName'
                noDescription'
                noInputs'
                noPermissions'
                noUsage'


-- ACTIONS

data ActionInput
    = ActionInput
    { description :: Maybe String
    , required    :: Maybe Bool
    , default'    :: Maybe String
    }
    deriving (Show)

$(deriveJSON defaultOptions{omitNothingFields = True, fieldLabelModifier = filter (/= '\'')} ''ActionInput)

type Inputs = Map String ActionInput

data Action
    = Action
    { name        :: String
    , description :: String
    , inputs      :: Maybe Inputs
    }
    deriving (Show)

$(deriveJSON defaultOptions{omitNothingFields = True, fieldLabelModifier = filter (/= '\'')} ''Action)

data ActionPermissionAccess
    = ReadAccess
    | WriteAccess
    deriving Eq

instance Read ActionPermissionAccess where
    readsPrec _ "read"  = [(ReadAccess, "")]
    readsPrec _ "write" = [(WriteAccess, "")]
    readsPrec _ _       = []

instance Show ActionPermissionAccess where
    show ReadAccess  = "read"
    show WriteAccess = "write"

type Permissions = Map String ActionPermissionAccess

data ActionMetadata
    = ActionMetadata
    { path        :: String
    , owner       :: Maybe String
    , project     :: Maybe String
    , version     :: Maybe String
    , permissions :: Maybe Permissions
    }
    deriving (Show, Eq)

toEnglishBool :: Bool -> String
toEnglishBool True  = "yes"
toEnglishBool False = "no"

actionStartTagPrefix :: String
actionStartTagPrefix = "<!-- gh-actions-docs-start"

actionEndTag :: String
actionEndTag = "<!-- gh-actions-docs-end -->"

prettyPrintAction :: Config -> Action -> ActionMetadata -> String
prettyPrintAction config (Action name' description' inputs') actionMetadata =
    (if noName config then "" else "## " ++ name' ++ "\n\n") ++
    (if noDescription config then "" else "### Description\n" ++ description' ++ "\n\n") ++
    (if noInputs config then "" else prettyPrintInputs inputs') ++
    (if noPermissions config then "" else prettyPrintPermissions actionMetadata) ++
    (if noUsage config then "" else prettyPrintUsage name' inputs' actionMetadata)

prettyPrintInputs :: Maybe Inputs -> String
prettyPrintInputs (Just inputs') =
    "### Inputs\n" ++
    "|Name|Description|Required|Default|\n"
        ++ "|-|-|-|-|\n"
        ++ concatMap
            ( \(name', ActionInput des req def) ->
                "`" ++ name' ++ "`"
                    ++ "|"
                    ++ fromMaybe "" des
                    ++ "|"
                    ++ maybe "no" toEnglishBool req
                    ++ "|"
                    ++ maybe "" (\def' -> "`" ++ def' ++ "`") def
                    ++ "|\n"
            )
            (toList inputs')
        ++ "\n"
prettyPrintInputs _ = ""

prettyPrintPermissions :: ActionMetadata -> String
prettyPrintPermissions (ActionMetadata _ _ _ _ (Just permissions')) =
    "### Permissions\n"
    ++ "This action requires the following [permissions](https://docs.github.com/en/actions/using-jobs/assigning-permissions-to-jobs):\n"
    ++ concatMap
            ( \(name', access) ->
                "- `" ++ name' ++ ": " ++ show access ++ "`\n"
            )
            (toList permissions')
    ++ "\n"
prettyPrintPermissions _ = ""


prettyPrintUsage :: String -> Maybe Inputs -> ActionMetadata -> String
prettyPrintUsage name' inputs' (ActionMetadata path' (Just owner') (Just project') (Just version') _) =
    "### Usage\n"++
    "```yaml\n"
        ++ "- name: " ++ name' ++ "\n"
        ++ "  uses: "
        ++ owner' ++ "/" ++ project' ++ actionPathWithoutFile ++ "@" ++ version' ++ "\n"
        ++ prettyPrintUsageWith inputs'
        ++ "```\n"
    where
        actionPathWithoutFile = prependSlashIfNotEmpty $ intercalate "/" . init . splitOn "/" $ path'
        prependSlashIfNotEmpty "" = ""
        prependSlashIfNotEmpty x  = "/" ++ x
prettyPrintUsage _ _ _ = ""

prettyPrintUsageWith :: Maybe Inputs -> String
prettyPrintUsageWith (Just inputs') = "  with:\n" ++ concatMap (uncurry prettyPrintUsageInputs) (toList inputs')
prettyPrintUsageWith Nothing = ""

prettyPrintUsageInputs :: String -> ActionInput -> String
prettyPrintUsageInputs name' (ActionInput des req def) =
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
        ++ "\n"
  where
    indent = replicate 4 ' '
    formatDescription des' = indent ++ "# " ++ des' ++ "\n" ++ indent ++ "#\n"
    formatRequired req' = indent ++ "# Required: " ++ toEnglishBool req' ++ "\n"
    formatDefault def' = indent ++ "# Default: '" ++ def' ++ "'\n"

actionMetadataToString :: ActionMetadata -> String
actionMetadataToString (ActionMetadata path' owner' project' version' permissions') =
    actionStartTagPrefix
        ++ " path="
        ++ path'
        ++ maybe "" (" owner=" ++) owner'
        ++ maybe "" (" project=" ++) project'
        ++ maybe "" (" version=" ++) version'
        ++ maybe "" permissionsToString permissions'
        ++ " -->"

permissionsToString :: Permissions -> String
permissionsToString permissions' =
    " permissions="
    ++ intercalate "," permissionStrList
    where
        permissionStrList =
            map
                (\(name', access) -> name' ++ ":" ++ show access)
                (toList permissions')

replaceActionTagWithDocs :: Config -> String -> (ActionMetadata, Action) -> String
replaceActionTagWithDocs config readme (meta, action) =
    case parse (skipManyTill latin1Char (specificActionMetadataParser_ meta)) "" (pack readme) of
        Right "" ->
            readme
        Right match' ->
            let docs = actionMetadataToString meta ++ "\n" ++ prettyPrintAction config action meta ++ actionEndTag
             in unpack $ replace (pack match') (pack docs) (pack readme)
        Left err ->
            error $ errorBundlePretty err


-- TABLE OF CONTENTS

data MarkdownHeader
    = MarkdownHeader
    { level :: Int
    , text  :: String
    }
    deriving (Show)

markdownHeadersToTableOfContents :: [MarkdownHeader] -> String
markdownHeadersToTableOfContents headers =
    markdownHeadersToTableOfContents' headers headers

markdownHeadersToTableOfContents' :: [MarkdownHeader] -> [MarkdownHeader] -> String
markdownHeadersToTableOfContents' xxs@(MarkdownHeader level' text' : xs) ys =
    replicate (2 * (level' - 1)) ' '
    ++ "- [" ++ text' ++ "]"
    ++ "(#" ++ slugify text' ++ headerIndexStr ++ ")\n"
    ++ markdownHeadersToTableOfContents' xs ys
  where
    headerIndexStr = if headerIndex == 0 then "" else "-" ++ show headerIndex
    headerIndex = countOccurences ys - countOccurences xxs
    countOccurences = length . filter ((== text') . text)
    slugify =
        unpack . toLower . replace " " "-" . pack . filter (`elem` [' ', '-'] ++ ['a' .. 'z'] ++ ['A' .. 'Z'] ++ ['0' .. '9'])
markdownHeadersToTableOfContents' [] _ = ""

tocStartTag :: String
tocStartTag = "<!-- gh-actions-docs-toc-start -->"

tocEndTag :: String
tocEndTag = "<!-- gh-actions-docs-toc-end -->"

replaceTableOfContentsTagWithTableOfContents :: String -> String -> String
replaceTableOfContentsTagWithTableOfContents toc readme =
    case parse (skipManyTill latin1Char tableOfContentsTagParser) "" (pack readme) of
        Right match' ->
            let toc' = tocStartTag ++ "\n" ++ toc ++ tocEndTag
             in unpack $ replace (pack match') (pack toc') (pack readme)
        Left err ->
            error $ errorBundlePretty err


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
    permissions' <- optional $ do
        _ <- string "permissions="
        permissions' <- permissionParser `sepBy` char ','
        _ <- char ' '
        return permissions'
    _ <- string "-->"
    _ <- skipManyTill anySingle $ string $ pack actionEndTag
    return $ ActionMetadata path' owner' project' version' (fromList <$> permissions')

permissionParser :: Parser (String, ActionPermissionAccess)
permissionParser = do
    name' <- manyTill anySingle (char ':')
    access' <- read . unpack <$> (string "read" <|> string "write")
    return (name', access')

fromTextActionMetadataParser :: Parser [ActionMetadata]
fromTextActionMetadataParser = do
    ps <- many $ try $ skipManyTill latin1Char actionMetadataParser
    _ <- eof <|> void newline
    return ps

specificActionMetadataParser_ :: ActionMetadata -> Parser String
specificActionMetadataParser_ meta = do
    meta' <- string (pack $ actionMetadataToString meta)
    (between', end) <- anySingle `manyTill_` string (pack actionEndTag)
    return $ unpack meta' ++ between' ++ unpack end

markdownHeaderParser :: Parser MarkdownHeader
markdownHeaderParser = do
    level' <- length <$> some (char '#')
    _ <- char ' '
    text' <- latin1Char `manyTill` newline
    return $ MarkdownHeader level' text'

tableOfContentsTagParser :: Parser String
tableOfContentsTagParser = do
    start <- skipManyTill anySingle $ string $ pack tocStartTag
    (between', end) <- manyTill_ anySingle $ string $ pack tocEndTag
    return $ unpack start ++ between' ++ unpack end


-- MAIN

updateActions :: Config -> String -> IO String
updateActions config readme = do
    -- Parse action metadata
    let actionMetadataListE = parse fromTextActionMetadataParser "" $ pack readme
    when (isLeft actionMetadataListE) do
        putStrLn "Error parsing metadata:"
        mapM_ pPrint actionMetadataListE
        exitFailure

    let actionMetadataList = filter (\file -> path file `notElem` ignoreFiles config) $ fromRight [] actionMetadataListE
    when (debug config) do
        putStrLn "actionMetdataList:"
        pPrint actionMetadataList

    -- Parse yaml in action files
    parsedFilesE <- mapM (decodeFileEither . path) actionMetadataList :: IO [Either ParseException Action]
    when (any isLeft parsedFilesE) do
        putStrLn "Error parsing files:"
        mapM_ pPrint $ lefts parsedFilesE
        exitFailure

    let parsedFiles = rights parsedFilesE
    when (debug config) do
        putStrLn "Parsed files:\n"
        mapM_ pPrint parsedFiles

    let parsedFilesWithMetadata = zip actionMetadataList parsedFiles
    when (debug config) do
        putStrLn "parsedFilesWithMetadata:"
        pPrint parsedFilesWithMetadata

    -- Update README with action docs
    let readmeWithActions = foldl (replaceActionTagWithDocs config) readme parsedFilesWithMetadata
    if readmeWithActions /= readme
        then do
            putStrLn $ readmeFile config ++ " updated successfully with documentation for actions!"
        else do
            putStrLn "No new changes to action documentation, not updated."

    return readmeWithActions

updateToc :: Config -> String -> IO String
updateToc config readme = do
    let markdownHeaderLines =
            map (++ "\n") $
                filter (`notElem` ignoreHeaders config) $
                    filter (\x -> any (`isPrefixOf` pack x) ["# ", "## ", "### ", "#### "]) $
                        lines readme
    when (debug config) do
        putStrLn "markdownHeadersLines:"
        pPrint markdownHeaderLines

    let markdownHeaders = map (parse markdownHeaderParser "" . pack) markdownHeaderLines
    when (any isLeft markdownHeaders) do
        putStrLn "Error parsing markdown headers:"
        mapM_ pPrint markdownHeaders
        exitFailure
    when (debug config) do
        putStrLn "markdownHeaders:"
        pPrint markdownHeaders

    -- Generate table of contents
    let toc = markdownHeadersToTableOfContents $ rights markdownHeaders
    when (debug config) do
        putStrLn "toc:"
        pPrint toc

    -- Update README with table of contents
    let readmeWithToc = replaceTableOfContentsTagWithTableOfContents toc readme
    if readmeWithToc /= readme then do
        putStrLn $ readmeFile config ++ " updated successfully with table of contents!"
    else do
        putStrLn "No new changes to table of contents, not updated."

    return readmeWithToc

main :: IO ()
main = do
    config <- getConfig
    when (debug config) do
        putStrLn "\nDebug mode enabled\n"
        putStrLn "Config:"
        pPrint config

    readme <- readFile $ readmeFile config

    case (noActions config, noToc config) of
        (False, False) ->
            updateActions config readme >>= updateToc config >>= writeFile (readmeFile config)
        (False, True) ->
            updateActions config readme >>= writeFile (readmeFile config)
        (True, False) ->
            updateToc config readme >>= writeFile (readmeFile config)
        (True, True) -> do
            putStrLn "Both NO_TOC and NO_ACTIONS are set to true, nothing to do."
            exitFailure

    when (runPrettier config) $
        callCommand ("prettier --write --single-quote " ++ readmeFile config)
