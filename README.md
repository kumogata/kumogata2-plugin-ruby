# kumogata2-plugin-ruby

It is the Ruby plug-in of [Kumogata2](https://github.com/winebarrel/kumogata2).

It convert the Ruby DSL to JSON.

[![Gem Version](https://badge.fury.io/rb/kumogata2-plugin-ruby.png?201406152020)](http://badge.fury.io/rb/kumogata2-plugin-ruby)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'kumogata2-plugin-ruby'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install kumogata2-plugin-ruby

## Usage

```sh
kumogata2 export my-stack --output-format rb > my-stack.rb
kumogata2 dry-run my-stack.rb my-stack
kumogata2 update my-stack.rb my-stack
```

### Export using braces

```sh
EXPORT_RUBY_USE_BRACES=1 kumogata2 export ... --output-format rb
```

### Export old format

```sh
EXPORT_RUBY_OLD_FORMAT=1 kumogata2 export ... --output-format rb
```

## Example

```ruby
template do
  AWSTemplateFormatVersion "2010-09-09"

  Description (<<-EOS).undent
    Kumogata Sample Template
    You can use Here document!
  EOS

  Parameters do
    InstanceType do
      Default "t2.micro"
      Description "Instance Type"
      Type "String"
    end
  end

  Resources do
    myEC2Instance do
      Type "AWS::EC2::Instance"
      Properties do
        ImageId "ami-XXXXXXXX"
        InstanceType { Ref "InstanceType" }
        KeyName "your_key_name"

        UserData do
          Fn__Base64 (<<-EOS).undent
            #!/bin/bash
            yum install -y httpd
            service httpd start
          EOS
        end
      end
    end
  end
end
```

* `::` is converted to `__`
  * `Fn::GetAtt` => `Fn__GetAtt`
* `_{ ... }` is convered to Hash
  * `SecurityGroups [_{Ref "WebServerSecurityGroup"}]` => `{"SecurityGroups": [{"Ref": "WebServerSecurityGroup"}]}`
* `_path()` creates Hash that has a key of path
  * `_path("/etc/passwd-s3fs") { content "..." }` => `{"/etc/passwd-s3fs": {"content": "..."}}`

### String#fn_join()

Ruby templates will be converted as follows by `String#fn_join()`:

```ruby
UserData do
  Fn__Base64 (<<-EOS).fn_join
    #!/bin/bash
    /opt/aws/bin/cfn-init -s <%= Ref "AWS::StackName" %> -r myEC2Instance --region <%= Ref "AWS::Region" %>
  EOS
end
```

```javascript
"UserData": {
  "Fn::Base64": {
    "Fn::Join": [
      "",
      [
        "#!/bin/bash\n",
        "/opt/aws/bin/cfn-init -s ",
        {
          "Ref": "AWS::StackName"
        },
        " -r myEC2Instance --region ",
        {
          "Ref": "AWS::Region"
        },
        "\n"
      ]
    ]
  }
}
```

### Split a template file

* template.rb

```ruby
template do
  Resources do
    _include 'template2.rb', :ami_id => 'ami-XXXXXXXX'
  end
end
```

* template2.rb

```ruby
myEC2Instance do
  Type "AWS::EC2::Instance"
  Properties do
    ImageId args[:ami_id]
    InstanceType { Ref "InstanceType" }
    KeyName "your_key_name"
  end
end
```

* Converted JSON template

```javascript
{
  "Resources": {
    "myEC2Instance": {
      "Type": "AWS::EC2::Instance",
      "Properties": {
        "ImageId": "ami-XXXXXXXX",
        "InstanceType": {
          "Ref": "InstanceType"
        },
        "KeyName": "your_key_name"
      }
    }
  }
}
```

### Post hook

You can run ruby script after building servers using `post()`.

```ruby
template do
  ...
end

post do |output|
  puts output
  #=> '{"WebsiteURL"=>"http://ec2-XX-XX-XX-XX.ap-northeast-1.compute.amazonaws.com"}'
end
```
