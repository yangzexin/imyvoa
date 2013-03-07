require "NSArray"
require "StringUtils"
require "common.lua"
require "DictDotCNDictionary.lua"

local kCommandAnalyseNewsList           = "analyse_news_list";
local kCommandAnalyseNewsContent        = "analyse_news_content";
local kCommandAnalyseNewsSoundURL       = "analyse_news_sound_url";
local kCommandGetNewsItemSeparator      = "news_item_separator";
local kCommandGetNewsItemLinkSeparator  = "news_item_link_separator";
local kCommandGetDictionaryName         = "dictionary_name";
local kCommandGetDictionaryURL          = "dictionary_url";
local kCommandAnalyseDictionaryContent  = "analyse_dictionary_content";
local kCommandGetNewsListURL            = "news_list_url";

function main(args)
    --po(args);
    local arr = NSArray:get(args);
    local command = nil;
    local arg = nil;
    if arr:count() ~= 0 then
        command = StringUtils.trim(StringUtils.toString(arr:objectAtIndex(0)));
    end
    if arr:count() > 1 then
        arg = StringUtils.toString(arr:objectAtIndex(1));
    end
    if command == kCommandAnalyseNewsList then
        return analyseNewsList(arg);
    elseif command == kCommandAnalyseNewsContent then
        local content = analyseNewsContent(arg);
        return content;
    elseif command == kCommandGetNewsItemSeparator then
        return itemSeparator();
    elseif command == kCommandGetNewsItemLinkSeparator then
        return linkSeparator();
    elseif command == kCommandGetDictionaryName then
        return dictionaryName();
    elseif command == kCommandGetDictionaryURL then
        return dictionaryURLForWord(StringUtils.trim(arg));
    elseif command == kCommandAnalyseDictionaryContent then
        return analyseDictionaryHTML(arg);
    elseif command == kCommandGetNewsListURL then
        return specialVOAURLString();
    elseif command == kCommandAnalyseNewsSoundURL then
        local soundURL = analyseSoundURL(arg);
        return soundURL;
    end
end