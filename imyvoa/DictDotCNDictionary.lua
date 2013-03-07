require "Utils"
require "common.lua"

function main(args)
    return analyseDictionaryHTML(args);
end

function analyseDictionaryHTML(HTML)
    --po(HTML);
    local beginIndex = ustring::find(HTML, "<div class=\"content\">", 0);
    local endIndex = ustring::find(HTML, "function checkForm(obj)", beginIndex);
    endIndex = ustring::find(HTML, "</div>", endIndex, true);
    endIndex = ustring::find(HTML, "</section>", endIndex, true);
    local content = ustring::substring(HTML, beginIndex, endIndex);
    content = removeTag(content, "a", false);
    return content;
end

function dictionaryName()
    return "在线词典";
end

function dictionaryURLForWord(word)
    local haiciURL = "http://3g.dict.cn/s.php?q=";
    word = string.gsub(word, " ", "+");
    
    return haiciURL..word;
end