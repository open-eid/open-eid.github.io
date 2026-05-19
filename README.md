# Architecture of ID-software

 * [Architecture of ID-software](http://open-eid.github.io)
 * [Domain Controller Configuration](http://open-eid.github.io/domain)
 * [Apache2 SSL Configuration](http://open-eid.github.io/apache)
 * [Nginx SSL Configuration](http://open-eid.github.io/nginx)
 * [IIS SSL Configuration](http://open-eid.github.io/iis)
 * [ID-software Administrator View](http://open-eid.github.io/admin)

## Editing and building "Architecture of ID-software"

Uses http://www.mkdocs.org/ and https://github.com/mkdocs/mkdocs-bootswatch styles for generating documentation.

1.  Update source files in ID_software_architecture_files/docs/

2.  Build documentation locally

        cd ID_software_architecture_files
        mkdocs build

## Editing and building "Domain Controller Configuration"

Uses https://jekyllrb.com and https://just-the-docs.com styles for generating documentation.

1.  Update source files in domain/

2.  Build the PDF document from the repository root

```bash
# Export English version
pandoc domain/index.md --resource-path=domain -L kramdown-toc.lua -o eID_Auth_Guide_EN.pdf

# Export Estonian version
pandoc domain/index.et.md --resource-path=domain -L kramdown-toc.lua -o eID_Auth_Guide_ET.pdf
```

## Editing and building "Apache2 SSL Configuration"

Uses https://jekyllrb.com and https://just-the-docs.com styles for generating documentation.

1.  Update source files in apache/

2.  Build the PDF document from the repository root

```bash
# Export English version
pandoc apache/index.md --resource-path=apache -L kramdown-toc.lua -o apache_SSL_EN.pdf

# Export Estonian version
pandoc apache/index.et.md --resource-path=apache -L kramdown-toc.lua -o apache_SSL_ET.pdf
```

## Editing and building "Nginx SSL Configuration"

Uses https://jekyllrb.com and https://just-the-docs.com styles for generating documentation.

1.  Update source files in nginx/

2.  Build the PDF document from the repository root

```bash
# Export English version
pandoc nginx/index.md --resource-path=nginx -L kramdown-toc.lua -o nginx_SSL_EN.pdf

# Export Estonian version
pandoc nginx/index.et.md --resource-path=nginx -L kramdown-toc.lua -o nginx_SSL_ET.pdf
```

## Editing and building "IIS SSL Configuration"

Uses https://jekyllrb.com and https://just-the-docs.com styles for generating documentation.

1.  Update source files in iis/

2.  Build the PDF document from the repository root

```bash
# Export English version
pandoc iis/index.md --resource-path=iis -L kramdown-toc.lua -o iis_SSL_EN.pdf

# Export Estonian version
pandoc iis/index.et.md --resource-path=iis -L kramdown-toc.lua -o iis_SSL_ET.pdf
```

## Editing and building "ID-software Administrator View"

Uses https://jekyllrb.com and https://just-the-docs.com styles for generating documentation.

1.  Update source files in admin/

2.  Build the PDF document from the repository root

```bash
# Export English version
pandoc admin/index.md --resource-path=admin -L kramdown-toc.lua -o admin_view_EN.pdf

# Export Estonian version
pandoc admin/index.et.md --resource-path=admin -L kramdown-toc.lua -o admin_view_ET.pdf
```

## Support
Official builds are provided through official distribution point [id.ee](https://www.id.ee/en/article/install-id-software/). If you want support, you need to be using official builds. Contact our support via www.id.ee for assistance.

Source code is provided on "as is" terms with no warranty (see license for more information). Do not file Github issues with generic support requests.
