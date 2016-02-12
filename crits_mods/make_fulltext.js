//invoke this with mongo localhost:27017/test make_fulltext.js from the percona server
//Knifehands


db = connect("localhost:27017/crits")
db.analysis_results.createIndex( { "$**": "text" }, {language_override: "dummy"}  )
db.backdoors.createIndex( { "$**": "text" } )
db.campaigns.createIndex( { "$**": "text" } )
db.comments.createIndex( { "$**": "text" } )
db.domains.createIndex( { "$**": "text" } )
db.emails.createIndex( { "$**": "text" } )
db.events.createIndex( { "$**": "text" } )
db.exploits.createIndex( { "$**": "text" } )
db.exploits.createIndex( { "$**": "text" } )
db.indicators.createIndex( { "$**": "text" } )
db.ips.createIndex( { "$**": "text" } )
db.notifications.createIndex( { "$**": "text" } )
db.raw_data.createIndex( { "$**": "text" } )
db.signature.createIndex( { "$**": "text" } )
db.samples.createIndex( { "$**": "text" } )
db.targets.createIndex( { "$**": "text" } )
db.screenshots.createIndex( { "$**": "text" } )