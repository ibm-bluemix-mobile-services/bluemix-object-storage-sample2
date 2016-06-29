'use strict'

var ObjectStorage = require('bluemix-objectstorage').ObjectStorage;
var _ = require('lodash');

var objStorage = new ObjectStorage();

function listPrivateContainer(req, res) {
    var objectList = [];
    var securityContext = req.securityContext;
    var containerName = securityContext['imf.user'].id;
    objStorage.getContainer(containerName)
        .then(function(container) {
            return container.listObjects();
        })
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

function fetchPrivateObject(req, res) {
    var objectName = req.swagger.params.object.value;
    var securityContext = req.securityContext;
    var containerName = securityContext['imf.user'].id;
    objStorage.getContainer(containerName)
        .then(function(container) {
            return container.getObject(objectName)
        })
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

function createPrivateObject(req, res) {
    var objectName = req.swagger.params.object.value;
    var data = req.body;
    var securityContext = req.securityContext;
    var containerName = securityContext['imf.user'].id;
    objStorage.getContainer(containerName)
        .then(function(container) {
            return container.createObject(objectName, data)
        })
        .then(function() {
            res.status(200).send();
        })
        .catch(function(err) {
            res.status(500).send(err.message);
        });
}

function deletePrivateObject(req, res) {
    var objectName = req.swagger.params.object.value;
    var securityContext = req.securityContext;
    var containerName = securityContext['imf.user'].id;
    objStorage.getContainer(containerName)
        .then(function(container) {
            return container.deleteObject(objectName)
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
    listPrivateContainer: listPrivateContainer,
    fetchPrivateObject: fetchPrivateObject,
    createPrivateObject: createPrivateObject,
    deletePrivateObject: deletePrivateObject
};