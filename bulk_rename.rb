# rename entire objects in specified bucket
#   ( hogehoge.txt => hogehoge.txt.md )

require 'bundler'
require 'yaml'
Bundler.require

settings = YAML.load_file('settings.yml')

bucketname = settings['default']['bucketname']

client = Aws::S3::Client.new(
    :access_key_id => settings['default']['access_key_id'],
    :secret_access_key => settings['default']['secret_access_key'],
    :region => settings['default']['region']
)

objects = client.list_objects(
    bucket: bucketname
)

puts "Total objects: #{objects.contents.size}"

renamed = 0

objects.contents.each do |obj|

    if !obj.key.match(/.+\/$/) && !obj.key.match(/.+\.md$/)

        obj_key_after = "#{obj.key}.md"

        client.copy_object(
            bucket: bucketname,
            copy_source: "#{bucketname}/#{obj.key}",
            key: obj_key_after
        )
        client.delete_object({
            bucket: bucketname,
            key: "#{obj.key}"
        });

        renamed += 1

        puts "#{obj.key} is renamed to #{obj_key_after}"
    end
end

puts "#{renamed} file(s) are successfuly renamed!"
