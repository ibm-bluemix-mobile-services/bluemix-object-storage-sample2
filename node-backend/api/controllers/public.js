
var ObjectStorage = require('bluemix-objectstorage').ObjectStorage;
var _ = require('lodash');

var objStorage = new ObjectStorage();

function listPublicContainer(req, res) {
    var objectList = [];
    objStorage.getContainer('public')
        .then(function(container) {
            return container.listObjects();
        })
        .then(function(list) {
            _.forEach(list, function(object) {
                var obj = { name: object.objectName() };
                objectList.push(obj);
            });
            res.status(200).json(objectList);
        })
        .catch(function(err) {
            res.status(500).send(err.message);
        });
}

function fetchPublicObject(req, res) {
    var objectName = req.swagger.params.object.value;
    var objStorageObj;
    objStorage.getContainer('public')
        .then(function(container) {
            return container.getObject(objectName);
        })
        .then(function(object) {
            objStorageObj = object;
            return object.load(false, true);
        })
        .then(function(content) {
            var contentType = objStorageObj.getContentType();
            res.header('Content-Type', contentType);
            res.status(200).send(content);
        })
        .catch(function(err) {
            if (err.name === 'ResourceNotFoundError') {
                res.status(404).send(err.message);
            }
            else {
                res.status(500).send(err.message);
            }
        });
}

function createPublicObject(req, res) {
    if (!req.headers['content-type']) {
        throw new ReferenceError('The "content-type" header must be set in order for this operation to success');
    }
    var objectName = req.swagger.params.object.value;
    var data = req.body;
    objStorage.getContainer('public')
        .then(function(container) {
            return container.createObject(objectName, data, true);
        })
        .then(function() {
            res.status(200).send();
        })
        .catch(function(err) {
            res.status(500).send(err.message);
        });
}

function deletePublicObject(req, res) {
    var objectName = req.swagger.params.object.value;
    objStorage.getContainer('public')
        .then(function(container) {
            return container.deleteObject(objectName);
        })
        .then(function() {
            res.status(200).send();
        })
        .catch(function(err) {
            if (err.name === 'ResourceNotFoundError') {
                res.status(404).send();
            }
            else {
                res.status(500).send();
            }
        });
}

module.exports = {
    listPublicContainer: listPublicContainer,
    fetchPublicObject: fetchPublicObject,
    createPublicObject: createPublicObject,
    deletePublicObject: deletePublicObject
};
