'use strict'

var ObjectStorage = require('bluemix-objectstorage').ObjectStorage;
var _ = require('lodash');

var objStorage = new ObjectStorage();
var container;

objStorage.getContainer('public')
    .then(function(objContainer) {
        container = objContainer;
    })
    .catch(function(err) {

    });

function listPublicContainer(req, res) {
    var objectList = [];
    container.listObjects()
        .then(function(list) {
            _.forEach(list, function(name) {
                var obj = { name: name };
                objectList.push(obj);
            });
            res.status(200).send(objectList);
        })
        .catch(function(err) {
            res.status(500).send(err.message);
        });
}

function fetchPublicObject(req, res) {
    var objectName = req.swagger.params.object.value;
    container.getObject(objectName)
        .then(function(object) {
            return object.load(false);
        })
        .then(function(content) {
            req.status(200).send(content);
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
    var objectName = req.swagger.params.object.value;
    var data = req.body;
    container.createObject(objectName, data)
        .then(function() {
            res.status(200).send();
        })
        .catch(function(err) {
            res.status(500).send(err.message);
        });
}

function deletePublicObject(req, res) {
    var objectName = req.swagger.params.object.value;
    container.deleteObject(objectName)
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
