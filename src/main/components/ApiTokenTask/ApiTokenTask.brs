sub init()
    m.top.functionName = "getContent"
end sub

sub getContent()
    content = CreateObject("roSGNode", "ContentNode")

    urlStr = "https://www.giantbomb.com/app/giant-bomber/get-result?format=json"
    urlStr = urlStr + "&regCode=" + m.top.code

    url = CreateObject("roUrlTransfer")
    url.SetCertificatesFile("common:/certs/ca-bundle.crt")
    url.InitClientCertificates()
    url.SetUrl(urlStr)
    response = url.GetToString()
    json = ParseJSON(response)
    content.AddFields(json)
    m.top.content = content
end sub
