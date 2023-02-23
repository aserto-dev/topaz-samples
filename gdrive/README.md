# Topaz Google Drive Sample

> **CREDITS**: This content is an adaptation of the [OpenFGA Google Drive Sample Store](https://github.com/openfga/sample-stores/blob/main/stores/gdrive/README.md) to demonstrate and compare how this scenario can be implemented and achieved using Topaz.


## Table of Content
- [Use-Case](#use-case)
  - [Requirements](#requirements)
  - [Scenario](#scenario)
  - [Expected Outcomes](#expected-outcomes)
- [Modeling in Topaz](#modeling-in-topaz)
  - [Model](#model)
  - [Tuples](#tuples)
  - [Assertions](#assertions)

## Use-Case

> Note: This is only a contrived subset of Google Drive's permissions meant to showcase how a system like Google Drive could be modeled

### Requirements

- There are users, groups, folders and documents
- Users can be members of groups
- Folders have owners
- Folders can have parent folders
- Folders have viewers, a folder's viewers are whoever has been directly granted viewer access, the viewers of the document's parent folders, or the owners of the document
- Users need to have the create file permission on a folder in order to create a file inside it (only the folder owner has this permission)
- Documents have owners
- Documents can have parent folders
- Documents can have viewers
- Only a document's direct owner can change ownership
- A document's owner or owners of the document's parent folder can share the document
- A document's owner or owners of the document's parent folder can write to the document
- The users who can read a document are those with viewer access to the document, those with viewer access to the document's parent folder or the document's owner

### Scenario

- Anne is a member of the Contoso group
- Beth is a member of the Contoso group
- Charles is a member of the Fabrikam group
- The "Product 2021" folder contains the "Public Roadmap" document
- The "Product 2021" folder contains the "2021 Roadmap" document
- Members of the Fabrikam group are viewers of the "Product 2021" folder
- Anne is a viewer of the "Product 2021" folder
- Beth is a viewer of the "2021 Roadmap" document
- Everyone is a viewer of the "Public Roadmap" document

### Expected Outcomes

- Anne can write to the "2021 Roadmap" document
- Beth **cannot** change the owner of the "2021 Roadmap" document
- Charles can read the "2021 Roadmap" document
- Charles **cannot** write to the "2021 Roadmap" document
- Daniel **cannot** read the "2021 Roadmap" document
- Daniel can read the "Public Roadmap" document
- Anne can write to the "Public Roadmap" document
- Charles **cannot** write the "Public Roadmap" document

## Modeling in Topaz
### Model (manifest.yaml)

```yaml
---
# folder (object type)
folder:
  # folder:owner (object relation)
  owner:
    # incl permissions of other object relations on the same object type
    union: 
    - parent
    - viewer
    - can_create_file

  # folder:parent (object relation)
  parent:
    union: 
    - viewer

  # folder:viewer (object relation)
  viewer:
    union:

  # folder:can_create_file (object relation)
  can_create_file:
    union:

# doc (object type)
doc:
  # doc:owner (object relation)
  owner:
    # incl permissions of other object relations on the same object type
    union:
    - parent
    - viewer
    - can_change_owner
    - can_share
    - can_write
    - can_read

  # doc:parent (object relation)
  parent:
    union:
    - viewer
    - can_share
    - can_write
    - can_read

  # doc:viewer (object relation)
  viewer:
    union:
    - can_read
  
  # doc:can_change_owner (object relation)
  can_change_owner:
    union:
  
  # doc:can_share (object relation)
  can_share:
    union:
  
  # doc:can_write (object relation)
  can_write:
    union:
  
  # doc:can_read (object relation)
  can_read:
    union:
```

The model is represented in this file: [manifest.yaml](./model/manifest.yaml)

### Tuples

| User                  | Relation | Object              | Description                                                            |
|-----------------------|----------|---------------------|------------------------------------------------------------------------|
| anne                  | member   | group:contoso       | Anne is a member of the Contoso group                                  |
| beth                  | member   | group:contoso       | Beth is a member of the Contoso group                                  |
| charles               | member   | group:fabrikam      | Charles is a member of the Fabrikam group                              |
| folder:product-2021   | parent   | doc:public-roadmap  | The "Product 2021" folder contains the "Public Roadmap" document       |
| folder:product-2021   | parent   | doc:2021-roadmap    | The "Product 2021" folder contains the "2021 Roadmap" document         |
| group:fabrikam#member | viewer   | folder:product-2021 | Members of the Fabrikam group are viewers of the "Product 2021" folder |
| anne                  | owner    | folder:product-2021 | Anne is a viewer of the "Product 2021" folder                          |
| beth                  | viewer   | doc:2021-roadmap    | Beth is a viewer of the "2021 Roadmap" document                        |
| *                     | viewer   | doc:public-roadmap  | Everyone is a viewer of the "Public Roadmap" document                  |

These are represented in these files: 

* [objects.json](./data/objects.json)
* [relations.json](./data/relations.json)

### Assertions

| User    | Relation     | Object             | Allowed? |
|---------|--------------|--------------------|----------|
| anne    | write        | doc:2021-roadmap   | Yes      |
| beth    | change_owner | doc:2021-roadmap   | No       |
| charles | read         | doc:2021-roadmap   | Yes      |
| charles | write        | doc:2021-roadmap   | No       |
| daniel  | read         | doc:2021-roadmap   | No       |
| daniel  | read         | doc:public-roadmap | Yes      |
| anne    | write        | doc:public-roadmap | Yes      |
| charles | write        | doc:public-roadmap | No       |

These are represented in this file: [assertions.json](./test/assertions.json).

## Validating the model

To validate the model described above:

1. Clone the topaz-samples repo:

	```
	mkdir -p ~/workspace/topaz
	cd ~/workspace/topaz
	git clone https://github.com/aserto-dev/topaz-samples.git
	```

2. Set the current working directory to the `gdrive` sample directory

	```
	cd ~/workspace/topaz/topaz-samples/gdrive
	```

3. Install a topaz instance, see [Topaz Getting Started](https://www.topaz.sh/docs/getting-started)

	```
	topaz install
	```

4. Configure the topaz instance, using:
 
	```
	topaz configure gdrive --resource=ghcr.io/aserto-policies/policy-template:latest -d -s
	```

5. Start your topaz instance, using:

	```
	topaz start
	```

6. Load the domain model, using the manifest file:

	```
	topaz load ./model/manifest.yaml --insecure
	```

7. Load the sample objects and relations, using:

	```
	topaz import --directory ./data --insecure
	```

8.	Validate the assertions, using:

	```
	./assert.sh
	``` 

9. Validate the results:

	```
	./assert.sh
	PASS
	PASS
	FAIL REQ:{"subject":{"type":"user","key":"charles"},"relation":{"name":"can_read","objectType":"doc"},"object":{"type":"doc","key":"2021-roadmap"}}
	PASS
	PASS
	FAIL REQ:{"subject":{"type":"user","key":"daniel"},"relation":{"name":"can_read","objectType":"doc"},"object":{"type":"doc","key":"public-roadmap"}}
	PASS
	PASS
	``` 

### NOTES:
The reason why assertions #3 and #6 are currently failing, is due to the fact they rely on two not yet supported capabilities in topaz, specificly:
 
#### Everyone to object relationship:

```{"user": "*", "relation": "viewer", "object": "doc:public-roadmap"}```

#### Userset to object relationship:

```{"user": "group:fabrikam#member", "relation": "viewer", "object": "folder:product-2021"}```

