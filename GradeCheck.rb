require 'rubygems'
require 'mechanize'
require 'nokogiri'

$path = "RESULTS.txt"

def signinAndgetResultsPage(username, password)
  a = Mechanize.new 
  a.user_agent_alias = 'Mac Firefox'
  a.follow_redirect = false
  #a.idle_timeout = 10

  a.get('https://evision.otago.ac.nz/sitsvision/wrd/siw_lgn') do |home_page|

    form = home_page.form_with('method'=>'POST')
    form.field_with('name'=>'MUA_CODE.DUMMY.MENSYS.1').value = username
    form.field_with('name'=>'PASSWORD.DUMMY.MENSYS.1').value = password
    
    #Sign in
    login_page = a.submit(form, form.buttons.first)
    
    #Save user and session cookies
    evision = a.cookie_jar.jar["evision.otago.ac.nz"]["/sitsvision/wrd/"]["EVISIONID"]
    jsession = a.cookie_jar.jar["evision.otago.ac.nz"]["/sitsvision/"]["JSESSIONID"]
    cookie = "test=cookiesEnabled; " + \
    "EVISIONLOGINLANG=\"\"; EVISIONLOGINHTV=\"\"; " + \
    "EVISIONID=\"#{evision.value}\";" +\
    "JSESSIONID=#{jsession.value}; " + \
    "__utma=205881805.1119558192.1445450541.1445450541.144545054" +\
    "1.1; __utmb=205881805.4.10.1445450541; __utmc=205881805; " +\
    "__utmz=205881805.1445450541.1.1.utmcsr=google|utmccn=(organic)"+\
    "|utmcmd=organic|utmctr=(not%20provided); __utmt=1"

    #Get user home page
    logged_in = a.get(login_page.links.first.uri, [], login_page, {'Cookie'=>cookie})
    #Get exams page
    results = a.get(logged_in.links_with(:text=>'Examinations and results')[0].uri, [], login_page, {'Cookie'=>cookie})
    #Get results page
    results = a.get(results.links_with(:text=>'My results')[0].uri, [], results, {'Cookie'=>cookie})
    #Return results
    return results.body
  end
end

#Returns a single table element with all the completed papers
def parseResults(search)
    body = Nokogiri::HTML(search)
    tables = body.xpath("html/body/div/div/div/div/div/form/table")
    complete = tables[tables.length-1]
    return complete
end

def getGrades(papers, table, regexp)
    results = Hash.new
    table.xpath('tr').each do |row|
        rows = Array.new
        row.xpath('td').each do |column|
            rows << column.content
        end
        if (rows[2] &&
            ((!regexp && (papers.include? rows[2] or papers.include? rows[3]))\
             or (regexp && rows[2].match(regexp))))
            results[rows[2]] = "#{rows[4]} (#{rows[5]})"
        end
    end
    return results
end

username = ARGV[0]
password = ARGV[1]
pattern = nil
#Let them provide a regular expression
if (ARGV.length > 2)
    pattern = Regexp::compile(ARGV[2])
end

if (!username || !password)
    puts "To run, enter: ruby GradeCheck.rb <username> <password>\
    <optional:regular expression>"
    puts "If you do not enter a regular expression, you will\
     be asked to enter the papers you want.
    eg: ruby GradeCheck.rb doejo123 password COSC2.."
    exit
end

if (!pattern)
    puts "Please enter each paper ID (case sensitive) separated by spaces: "
    papers = STDIN.gets
    papers = papers.split(" ")
end

results = signinAndgetResultsPage(username, password)
complete = parseResults(results)
found = getGrades(papers, complete, pattern)

output = File.new($path, "w+")
output.write("Remember to delete the scheduler from /Library/LaunchAgents when finished.")

#print results
if (pattern)
    found.each do |paper, grade|
        output.write "In #{paper}, you got #{grade}\n"
    end
    if (found.empty?)
        output = nil
        File.delete($path)
    end
else
    papers.each do |paper|
        if (found[paper])
            output.write "In #{paper}, you got #{found[paper]}\n"
        else
            output.write "Still waiting for results for #{paper}\n"
        end
    end
end








