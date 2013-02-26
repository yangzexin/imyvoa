
require "Utils"

function main(args)
    return analyseHTML(args);
end

function analyseHTML(HTML)
    --po(HTML);
    local beginIndex = ustring::find(HTML, "<div class=\"content\">", 0);
    local endIndex = ustring::find(HTML, "function checkForm(obj)", beginIndex);
    endIndex = ustring::find(HTML, "</div>", endIndex, true);
    endIndex = ustring::find(HTML, "</section>", endIndex, true);
    local content = ustring::substring(HTML, beginIndex, endIndex);
    content = removeTag(content, "a", false);
    return content;
end

function removeTag(html, tagName, removeContent)
	local tagBegin = "<"..tagName;
	local tagEnd = "</"..tagName..">";
    
	local resultStr = html;
	local prefix = "";
	local suffix = "";
	local beginIndex = 0;
	local endIndex = 0;
	local beginIndex2 = 0;
	local endIndex2 = 0;
	
	while true do
		beginIndex, endIndex = string.find(resultStr, tagBegin);
		if beginIndex == nil then
			break;
		end
		if removeContent then
			beginIndex2, endIndex2 = string.find(resultStr, tagEnd, endIndex);
            else
			beginIndex2, endIndex2 = string.find(resultStr, ">", endIndex);
		end
		
		prefix = string.sub(resultStr, 0, beginIndex - 1);
		suffix = string.sub(resultStr, endIndex2 + 1, string.len(resultStr));
		resultStr = prefix..suffix;
	end
	resultStr = string.gsub(resultStr, tagEnd, "");
	return resultStr;
end