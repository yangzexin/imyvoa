function baseURLString()
    return "http://www.51voa.com";
end

function specialVOAURLString()
    return "http://www.51voa.com/VOA_Special_English/";
    --return "http://www.51voa.com/VOA_Standard_English/";
end

function linkSeparator()
    return "-*-*-";
end

function itemSeparator()
    return "-|-|-";
end

function analyseSingleLi(liHtml)
    liHtmlReversed = string.reverse(liHtml);
    local beginIndex1, endIndex1 = string.find(liHtmlReversed, "\"=ferh a<");
    titleAndLinkHtml = string.reverse(string.sub(liHtmlReversed, 1, beginIndex1 - 1));
    
    local beginIndex2, endIndex2 = string.find(titleAndLinkHtml, "\"");
    local newsLink = baseURLString()..string.sub(titleAndLinkHtml, 1, beginIndex2 - 1);
    
    local beginIndex3, endIndex3 = string.find(titleAndLinkHtml, ">");
    local beginIndex4, endIndex4 = string.find(titleAndLinkHtml, "</");
    local newsTitle = string.sub(titleAndLinkHtml, endIndex3 + 1, beginIndex4 - 1);
    
    return newsTitle, newsLink;
end

function analyseNewsList(html)
    print(html);
	local beginIndex, endIndex = string.find(html, "<div id=\"list\">");
	local beginIndex2, endIndex2 = string.find(html, "</div>", endIndex);
	html = string.sub(html, endIndex + 1, beginIndex2 - 1);

	endIndex2 = 0;
	resultStr = "";
	while true do
		beginIndex, endIndex = string.find(html, "<li>", endIndex2);
		if beginIndex == nil then
			break;
		end
		beginIndex2, endIndex2 = string.find(html, "</li>", endIndex);
		linkItemStr = string.sub(html, endIndex + 1, beginIndex2 - 1);
        
        local newsTitle, newsLink = analyseSingleLi(linkItemStr);
        
        resultStr = resultStr..newsLink..linkSeparator()..newsTitle..itemSeparator();
	end
	return resultStr;
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

function analyseNewsContent(htmlContent)
	if string.len(htmlContent) == 0 then
		return wrapNewsContent("No content yet");
	end
    
    local beginIndex1, endIndex1 = string.find(htmlContent, "<div id=\"menubar\">");
    local beginIndex2, endIndex2 = string.find(htmlContent, "<div id=\"Bottom_VOA\">", endIndex1);
    beginIndex2, endIndex2 = string.find(htmlContent, "</div>", endIndex2);
    
    local fixContent = string.sub(htmlContent, endIndex1 + 1, beginIndex2 - 1);
    fixContent = removeTag(fixContent, "DIV", true);
    fixContent = removeTag(fixContent, "SPAN", false);
    fixContent = removeTag(fixContent, "A", false);
    fixContent = removeTag(fixContent, "a", true);
    fixContent = removeTag(fixContent, "img", false);
    fixContent = removeTag(fixContent, "IMG", false);
    fixContent = wrapNewsContent(fixContent);
    return fixContent;
end

function wrapNewsContent(content)
    --content = string.gsub(content, "51voa.com", "<a href='http://learningenglish.voanews.com'>VOASpecialEnglish.com</a>");
    content = string.gsub(content, "51voa.com", "VOASpecialEnglish.com");
	local html = "<html><head>";
	html = html.."<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">";
	html = html.."<meta name=\"viewport\" content=\"width=device-width,minimum-scale=1.0,maximum-scale=1.0,user-scalable=no\">";
	html = html.."<meta name=\"format-detection\" content=\"telephone=no\">";
	html = html.."</head>";
	html = html.."<body style=\"padding-top:0px;padding-bottom:44px;\">";
    html = html.."$title";
    html = html.."<div style=\"font-family:Verdana;\">";
	html = html..content;
    html = html.."</div>";
	html = html.."</body>";
	html = html.."</html>";

	return html;
end

function analyseSoundURL(html)
    local beginIndex, endIndex = string.find(html, "http://down.51voa.com/");
    if beginIndex then
        local beginIndex2, endIndex2 = string.find(html, "\"", beginIndex);
        local sound = string.sub(html, beginIndex, beginIndex2 - 1);
        return sound;
    end
    
    return "";
end

