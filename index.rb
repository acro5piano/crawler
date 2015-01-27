#!/usr/bin/ruby -Ku

require "cgi"
cgi = CGI.new

if cgi['config'] != "" then
	file = File.open("./config.json", "w")
	file.puts(cgi['config'].gsub(/\r/,""))
	file.close
end

print("content-type: text/html\n\n")                                                                                                                                    

print <<EOM
		<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
		<html lang="ja">
		<head>
			<title>CRAWLER</title>
			<link rel="stylesheet" href="./style.css" type="text/css" media="screen" />
			<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		</head>
		<body>
		<div id="header">
			<h1>CRALER</h1>
		</div>
		<div id="wrapper">
			<input type="submit" value="GO!" class="button_next" onclick="window.open('extract.rb')" target="_blank" />
			<p>&nbsp;</p>
			<h2>設定</h2>
			<form method="POST" action="./index.rb">
				<textarea name="config">
EOM
open("config.json").each {|line|print line}
print <<EOM
</textarea>
				<input type="submit" value="設定変更" class="button_next" />
			</form>
		</div>
		<div id="footer">
			<span class="footer_link"><a href="">利用規約</a></span>
			<span class="footer_link"><a href="">プライバシーポリシー</a></span>
		</div>
		</body>
		</html>
</html>
EOM

