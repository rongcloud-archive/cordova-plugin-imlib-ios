/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

var RongCloudLibPluginClient = {
    RCPC_init: function () {
        alert ("RCPC_init");
        window.RongCloudLibPlugin.init(
                    function(result) { alert( "success: " + result.status ); },
                    function(error) { alert( "error: " + error.msg ); },
                    {
                        appKey: "z3v5yqkbv8v30",
                        deviceToken: "87jjfds8393sfjds83"
                    }
        );
    },
    RCPC_setConnectionStatusListener: function () {
        alert ("RCPC_setConnectionStatusListener");
        window.RongCloudLibPlugin.setConnectionStatusListener(
                    function(result) { alert( "success: " + result.status ); },
                    function(error) { alert( "error: " + error.msg ); }
        );
    },
    RCPC_setOnReceiveMessageListener: function () {
        alert ("RCPC_setOnReceiveMessageListener");
        window.RongCloudLibPlugin.setOnReceiveMessageListener(
                    function(result) { alert( "success: " + result.status ); },
                    function(error) { alert( "error: " + error ); }
        );
    },
    RCPC_connect: function () {
        alert ("RCPC_connect");
        window.RongCloudLibPlugin.connect(
                    function(result) { alert( "success: " + result.result ); },
                    function(error) { alert( "error: " + error.msg ); },
                    {
                        token: "nNvfq+uY7f5Nn8SmFPPw5kmcbyeYIrXSDa0nFvL2mH+qisY908p5KQeQ6zNg4jNgGIXebCOleFVkSSl4BaK1gQ=="
                    }
        );
    },
    RCPC_reconnect: function () {
        alert ("RCPC_reconnect");
        window.RongCloudLibPlugin.reconnect(
                    function(result) { alert( "success: " + result.status ); },
                    function(error) { alert( "error: " + error.msg ); }

        );
    },
    RCPC_disconnect: function () {
        alert ("RCPC_disconnect");
        window.RongCloudLibPlugin.disconnect(
                    function(result) { alert( "success: " + result.status ); },
                    function(error) { alert( "error: " + error.msg ); },
                    {
                        isReceivePush: false
                    }
        );
    },

    RCPC_sendTextMessage: function () {
        alert ("RCPC_sendTextMessage");
        window.RongCloudLibPlugin.sendTextMessage(
                    function(result) { alert( "success: " + result.result ); },
                    function(error) { alert( "error: " + error.msg ); },
                    {
                        conversationType: "PRIVATE",
                        targetId: "16",
                        text: "hello world",
                        extra: "this is a extra text"
                    }
        );
    },
    RCPC_sendImageMessage: function () {
        alert ("RCPC_sendImageMessage");
        window.RongCloudLibPlugin.sendImageMessage(
                    function(result) { alert( "success: " + result.result ); },
                    function(error) { alert( "error: " + error.msg ); },
                    {
                        conversationType: "PRIVATE",
                        targetId: "16",
                        imagePath: "/var/mobile/Applications/0369D904-6019-4C05-B619-2F697A3BA543/Documents/9119/Cache/private/9119/image/image_jpeg_RC-0115-02-25_673_1427250734",
                        extra: "this is a extra text"
                    }
        );
    },
    RCPC_sendVoiceMessage: function () {
        alert ("RCPC_sendVoiceMessage");
        window.RongCloudLibPlugin.sendVoiceMessage(
                    function(result) { alert( "success: " + result.result ); },
                    function(error) { alert( "error: " + error.msg ); },
                    {
                        conversationType: "PRIVATE",
                        targetId: "16",
                        voicePath: "/var/mobile/Applications/0369D904-6019-4C05-B619-2F697A3BA543/Documents/9119/Cache/private/9119/image/image_jpeg_RC-0115-02-25_673_1427250734",
                        duration: 3,
                        extra: "this is a extra text"
                    }
        );
    },
    RCPC_sendLocationMessage: function () {
        alert ("RCPC_sendLocationMessage");
        window.RongCloudLibPlugin.sendLocationMessage(
                    function(result) { alert( "success: " + result.result ); },
                    function(error) { alert( "error: " + error.msg ); },
                    {
                        conversationType: "PRIVATE",
                        targetId: "16",
                        latitude: 39.8802147,
                        longitude: 116.415794,
                        poi: "location_poi_info",
                        imageUri:"http://rongcloud.cn/images/logo.png",
                        extra: "this is a extra text"
                    }
        );
    },
    RCPC_sendRichContentMessage: function () {
        alert ("RCPC_sendRichContentMessage");
        window.RongCloudLibPlugin.sendRichContentMessage(
                    function(result) { alert( "success: " + result.result ); },
                    function(error) { alert( "error: " + error.msg ); },
                    {
                        conversationType: 'PRIVATE',
                        targetId: 'apicloud002',
                        title:"rongCloud", // 消息的标题.
                        description: '融云SDK APICloud 版', // 消息的简介.
                        imageUrl: 'http://abfc6f80482f86f9ccf4.b0.upaiyun.com/apicloud/5b67af4da9ce31f101c3326fbef10e5e.png', // 消息图片的网络地址.
                        extra: 'From APICloud' // 消息的附加信息.
                    }
        );
    },
    RCPC_sendCommandNotificationMessage: function () {
        alert ("RCPC_sendCommandNotificationMessage");
        window.RongCloudLibPlugin.sendCommandNotificationMessage(
                    function(result) { alert( "success: " + result.result ); },
                    function(error) { alert( "error: " + error.msg ); },
                    {
                        conversationType: "PRIVATE",
                        targetId: "16",
                        name: "commont_name",
                        data: "commont_data"
                    }
        );
    },
    RCPC_getConversationList: function () {
        alert ("RCPC_getConversationList");
        window.RongCloudLibPlugin.getConversationList(
                    function(result) { alert( "success: " + result.result ); },
                    function(error) { alert( "error: " + error.msg ); }
        );
    },
    RCPC_getConversation: function () {
        alert ("RCPC_getConversation");
        window.RongCloudLibPlugin.getConversation(
                    function(result) { alert( "success: " + result.result ); },
                    function(error) { alert( "error: " + error.msg ); },
                    {
                        conversationType: "PRIVATE",
                        targetId: "13"
                    }
        );
    },
    RCPC_removeConversation: function () {
        alert ("RCPC_removeConversation");
        window.RongCloudLibPlugin.removeConversation(
                    function(result) { alert( "success: " + result.result ); },
                    function(error) { alert( "error: " + error.msg ); },
                    {
                        conversationType: "PRIVATE",
                        targetId: "16"
                    }
        );
    },
    RCPC_clearConversations: function () {
        alert ("RCPC_clearConversations");
        window.RongCloudLibPlugin.clearConversations(
                    function(result) { alert( "success: " + result.status ); },
                    function(error) { alert( "error: " + error.msg ); },
                    {
                        conversationTypes: ["GROUP", "DISCUSSION"]
                    }
        );
    },
    RCPC_setConversationToTop: function () {
        alert ("RCPC_setConversationToTop");
        window.RongCloudLibPlugin.setConversationToTop(
                    function(result) { alert( "success: " + result.status ); },
                    function(error) { alert( "error: " + error.msg ); },
                    {
                        conversationType: "PRIVATE",
                        targetId: "16",
                        isTop: true
                    }
        );
    },
    RCPC_getConversationNotificationStatus: function () {
        alert ("RCPC_getConversationNotificationStatus");
        window.RongCloudLibPlugin.getConversationNotificationStatus(
                    function(result) { alert( "success: " + result.result ); },
                    function(error) { alert( "error: " + error.msg ); },
                    {
                        conversationType: "PRIVATE",
                        targetId: "13"
                    }
        );
    },
    RCPC_setConversationNotificationStatus: function () {
        alert ("RCPC_setConversationNotificationStatus");
        window.RongCloudLibPlugin.setConversationNotificationStatus(
                    function(result) { alert( "success: " + result.result ); },
                    function(error) { alert( "error: " + error.msg ); },
                    {
                        conversationType: "PRIVATE",
                        targetId: "16",
                        notificationStatus: "DO_NOT_DISTURB"
                    }
        );
    },
    RCPC_getLatestMessages: function () {
        alert ("RCPC_getLatestMessages");
        window.RongCloudLibPlugin.getLatestMessages(
                    function(result) { alert( "success: " + result.result ); },
                    function(error) { alert( "error: " + error.msg ); },
                    {
                        conversationType: "PRIVATE",
                        targetId: "16",
                        count: 2
                    }
        );
    },
    RCPC_getHistoryMessages: function () {
        alert ("RCPC_getHistoryMessages");
        window.RongCloudLibPlugin.getHistoryMessages(
                    function(result) { alert( "success: " + result.result ); },
                    function(error) { alert( "error: " + error.msg ); },
                    {
                        conversationType: "PRIVATE",
                        targetId: "16",
                        count: 2,
                        oldestMessageId: 10
                    }
        );
    },
    RCPC_getHistoryMessagesByObjectName: function () {
        alert ("RCPC_getHistoryMessagesByObjectName");
        window.RongCloudLibPlugin.getHistoryMessagesByObjectName(
                    function(result) { alert( "success: " + result.result ); },
                    function(error) { alert( "error: " + error.msg ); },
                    {
                        conversationType: "PRIVATE",
                        targetId: "16",
                        count: 2,
                        oldestMessageId: 10,
                        objectName: "RC:ImgMsg"
                    }
        );
    },
    RCPC_deleteMessages: function () {
        alert ("RCPC_deleteMessages");
        window.RongCloudLibPlugin.deleteMessages(
                    function(result) { alert( "success: " + result.status ); },
                    function(error) { alert( "error: " + error.msg ); },
                    {
                        messageIds: [1, 2, 3]
                    }
        );
    },
    RCPC_clearMessages: function () {
        alert ("RCPC_clearMessages");
        window.RongCloudLibPlugin.clearMessages(
                    function(result) { alert( "success: " + result.status ); },
                    function(error) { alert( "error: " + error.msg ); },
                    {
                        conversationType: "PRIVATE",
                        targetId: "16"
                    }
        );
    },
    RCPC_getTotalUnreadCount: function () {
        alert ("RCPC_getTotalUnreadCount");
        window.RongCloudLibPlugin.getTotalUnreadCount(
                    function(result) { alert( "success: " + result.result ); },
                    function(error) { alert( "error: " + error.msg ); }
        );
    },
    RCPC_getUnreadCount: function () {
        alert ("RCPC_getUnreadCount");
        window.RongCloudLibPlugin.getUnreadCount(
                    function(result) { alert( "success: " + result.result ); },
                    function(error) { alert( "error: " + error.msg ); },
                    {
                        conversationType: "PRIVATE",
                        targetId: "16"
                    }
        );
    },
    RCPC_getUnreadCountByConversationTypes: function () {
        alert ("RCPC_getUnreadCountByConversationTypes");
        window.RongCloudLibPlugin.getUnreadCountByConversationTypes(
                    function(result) { alert( "success: " + result.result ); },
                    function(error) { alert( "error: " + error.msg ); },
                    {
                        conversationTypes: ["PRIVATE", "GROUP", "DISCUSSION"]
                    }
        );
    },
    RCPC_setMessageReceivedStatus: function () {
        alert ("RCPC_setMessageReceivedStatus");
        window.RongCloudLibPlugin.setMessageReceivedStatus(
                    function(result) { alert( "success: " + result.status ); },
                    function(error) { alert( "error: " + error.msg ); },
                    {
                        messageId: 1,
                        receivedStatus:2
                    }
        );
    },
    RCPC_clearMessagesUnreadStatus: function () {
        alert ("RCPC_clearMessagesUnreadStatus");
        window.RongCloudLibPlugin.clearMessagesUnreadStatus(
                    function(result) { alert( "success: " + result.status ); },
                    function(error) { alert( "error: " + error.msg ); },
                    {
                        conversationType: "PRIVATE",
                        targetId: "16"
                    }
        );
    },
    RCPC_setMessageExtra: function () {
        alert ("RCPC_setMessageExtra");
        window.RongCloudLibPlugin.setMessageExtra(
                    function(result) { alert( "success: " + result.status ); },
                    function(error) { alert( "error: " + error.msg ); },
                    {
                        messageId: 1,
                        value: "test"
                    }
        );
    },
    RCPC_getTextMessageDraft: function () {
        alert ("RCPC_getTextMessageDraft");
        window.RongCloudLibPlugin.getTextMessageDraft(
                    function(result) { alert( "success: " + result.result ); },
                    function(error) { alert( "error: " + error.msg ); },
                    {
                        conversationType: "PRIVATE",
                        targetId: "16"
                    }
        );
    },
    RCPC_saveTextMessageDraft: function () {
        alert ("RCPC_saveTextMessageDraft");
        window.RongCloudLibPlugin.saveTextMessageDraft(
                    function(result) { alert( "success: " + result.result ); },
                    function(error) { alert( "error: " + error.msg ); },
                    {
                        conversationType: "PRIVATE",
                        targetId: "16",
                        content: "test_draft"
                    }
        );
    },
    RCPC_clearTextMessageDraft: function () {
        alert ("RCPC_clearTextMessageDraft");
        window.RongCloudLibPlugin.clearTextMessageDraft(
                    function(result) { alert( "success: " + result.status ); },
                    function(error) { alert( "error: " + error.msg ); },
                    {
                        conversationType: "PRIVATE",
                        targetId: "16"
                    }
        );
    },
    RCPC_createDiscussion: function () {
        alert ("RCPC_createDiscussion");
        window.RongCloudLibPlugin.createDiscussion(
                    function(result) { alert( "success: " + result.result ); },
                    function(error) { alert( "error: " + error.msg ); },
                    {
                        name: "discussion",
                        userIdList: ["16", "4345"]
                    }
        );
    },
    RCPC_getDiscussion: function () {
        alert ("RCPC_getDiscussion");
        window.RongCloudLibPlugin.getDiscussion(
                    function(result) { alert( "success: " + result.result ); },
                    function(error) { alert( "error: " + error.msg ); },
                    {
                        discussionId: "1b9f7abe-a5ae-463d-8ff8-d96deaf40b59"
                    }
        );
    },
    RCPC_setDiscussionName: function () {
        alert ("RCPC_setDiscussionName");
        window.RongCloudLibPlugin.setDiscussionName(
                    function(result) { alert( "success: " + result.status ); },
                    function(error) { alert( "error: " + error.msg ); },
                    {
                        discussionId: "1b9f7abe-a5ae-463d-8ff8-d96deaf40b59",
                        name: "test_discussion_name"
                    }
        );
    },
    RCPC_addMemberToDiscussion: function () {
        alert ("RCPC_addMemberToDiscussion");
        window.RongCloudLibPlugin.addMemberToDiscussion(
                    function(result) { alert( "success: " + result.status ); },
                    function(error) { alert( "error: " + error.msg ); },
                    {
                        discussionId: "1b9f7abe-a5ae-463d-8ff8-d96deaf40b59",
                        userIdList: ["16", "4345"]
                    }
        );
    },
    RCPC_removeMemberFromDiscussion: function () {
        alert ("RCPC_removeMemberFromDiscussion");
        window.RongCloudLibPlugin.removeMemberFromDiscussion(
                    function(result) { alert( "success: " + result.result ); },
                    function(error) { alert( "error: " + error.msg ); },
                    {
                        discussionId: "1b9f7abe-a5ae-463d-8ff8-d96deaf40b59",
                        userId: "26"
                    }
        );
    },
    RCPC_quitDiscussion: function () {
        alert ("RCPC_quitDiscussion");
        window.RongCloudLibPlugin.quitDiscussion(
                    function(result) { alert( "success: " + result.status ); },
                    function(error) { alert( "error: " + error.msg ); },
                    {
                        discussionId: "1b9f7abe-a5ae-463d-8ff8-d96deaf40b59"
                    }
        );
    },
    RCPC_setDiscussionInviteStatus: function () {
        alert ("RCPC_setDiscussionInviteStatus");
        window.RongCloudLibPlugin.setDiscussionInviteStatus(
                    function(result) { alert( "success: " + result.result ); },
                    function(error) { alert( "error: " + error.msg ); },
                    {
                        discussionId: "ac62578f-601b-49aa-99cb-9e90dac84fde",
                        inviteStatus: "CLOSED"
                    }
        );
    },
    RCPC_syncGroup: function () {
        alert ("RCPC_syncGroup");
        window.RongCloudLibPlugin.syncGroup(
                    function(result) { alert( "success: " + result.status ); },
                    function(error) { alert( "error: " + error.msg ); },
                    {
                        groups: [{
                            id: "group_id",
                            name: "group_name",
                            portraitUrl: "http://XXX"
                        }, {
                            id: "group_id2",
                            name: "group_name2",
                            portraitUrl: "http://XXX"
                        }]
                    }
        );
    },
    RCPC_joinGroup: function () {
        alert ("RCPC_joinGroup");
        window.RongCloudLibPlugin.joinGroup(
                    function(result) { alert( "success: " + result.status ); },
                    function(error) { alert( "error: " + error.msg ); },
                    {
                        groupId: "group_id",
                        groupName: "group_name"
                    }
        );
    },
    RCPC_quitGroup: function () {
        alert ("RCPC_quitGroup");
        window.RongCloudLibPlugin.quitGroup(
                    function(result) { alert( "success: " + result.status ); },
                    function(error) { alert( "error: " + error.msg ); },
                    {
                        groupId: "group_id"
                    }
        );
    },
    RCPC_joinChatRoom: function () {
        alert ("RCPC_joinChatRoom");
        window.RongCloudLibPlugin.joinChatRoom(
                    function(result) { alert( "success: " + result.status ); },
                    function(error) { alert( "error: " + error.msg ); },
                    {
                        chatRoomId: "chatroom",
                        defMessageCount: 10
                    }
        );
    },
    RCPC_quitChatRoom: function () {
        alert ("RCPC_quitChatRoom");
        window.RongCloudLibPlugin.quitChatRoom(
                    function(result) { alert( "success: " + result.status ); },
                    function(error) { alert( "error: " + error.msg ); },
                    {
                        chatRoomId: "chatroom"
                    }
        );
    }
};

var app = {
    // Application Constructor
    initialize: function() {
        this.bindEvents();
    },
    // Bind Event Listeners
    //
    // Bind any events that are required on startup. Common events are:
    // 'load', 'deviceready', 'offline', and 'online'.
    bindEvents: function() {
        document.addEventListener('deviceready', this.onDeviceReady, false);
        document.getElementById("RCPC_init").addEventListener('click', RongCloudLibPluginClient.RCPC_init, false);
        document.getElementById("RCPC_setConnectionStatusListener").addEventListener('click', RongCloudLibPluginClient.RCPC_setConnectionStatusListener, false);
        document.getElementById("RCPC_setOnReceiveMessageListener").addEventListener('click', RongCloudLibPluginClient.RCPC_setOnReceiveMessageListener, false);
        document.getElementById("RCPC_connect").addEventListener('click', RongCloudLibPluginClient.RCPC_connect, false);
        document.getElementById("RCPC_reconnect").addEventListener('click', RongCloudLibPluginClient.RCPC_reconnect, false);
        document.getElementById("RCPC_disconnect").addEventListener('click', RongCloudLibPluginClient.RCPC_disconnect, false);
        document.getElementById("RCPC_sendTextMessage").addEventListener('click', RongCloudLibPluginClient.RCPC_sendTextMessage, false);
        document.getElementById("RCPC_sendImageMessage").addEventListener('click', RongCloudLibPluginClient.RCPC_sendImageMessage, false);
        document.getElementById("RCPC_sendVoiceMessage").addEventListener('click', RongCloudLibPluginClient.RCPC_sendVoiceMessage, false);
        document.getElementById("RCPC_sendLocationMessage").addEventListener('click', RongCloudLibPluginClient.RCPC_sendLocationMessage, false);
        document.getElementById("RCPC_sendRichContentMessage").addEventListener('click', RongCloudLibPluginClient.RCPC_sendRichContentMessage, false);
        document.getElementById("RCPC_sendCommandNotificationMessage").addEventListener('click', RongCloudLibPluginClient.RCPC_sendCommandNotificationMessage, false);
        document.getElementById("RCPC_getConversationList").addEventListener('click', RongCloudLibPluginClient.RCPC_getConversationList, false);
        document.getElementById("RCPC_getConversation").addEventListener('click', RongCloudLibPluginClient.RCPC_getConversation, false);
        document.getElementById("RCPC_removeConversation").addEventListener('click', RongCloudLibPluginClient.RCPC_removeConversation, false);
        document.getElementById("RCPC_clearConversations").addEventListener('click', RongCloudLibPluginClient.RCPC_clearConversations, false);
        document.getElementById("RCPC_setConversationToTop").addEventListener('click', RongCloudLibPluginClient.RCPC_setConversationToTop, false);
        document.getElementById("RCPC_getConversationNotificationStatus").addEventListener('click', RongCloudLibPluginClient.RCPC_getConversationNotificationStatus, false);
        document.getElementById("RCPC_setConversationNotificationStatus").addEventListener('click', RongCloudLibPluginClient.RCPC_setConversationNotificationStatus, false);
        document.getElementById("RCPC_getLatestMessages").addEventListener('click', RongCloudLibPluginClient.RCPC_getLatestMessages, false);
        document.getElementById("RCPC_getHistoryMessages").addEventListener('click', RongCloudLibPluginClient.RCPC_getHistoryMessages, false);
        document.getElementById("RCPC_getHistoryMessagesByObjectName").addEventListener('click', RongCloudLibPluginClient.RCPC_getHistoryMessagesByObjectName, false);
        document.getElementById("RCPC_deleteMessages").addEventListener('click', RongCloudLibPluginClient.RCPC_deleteMessages, false);
        document.getElementById("RCPC_clearMessages").addEventListener('click', RongCloudLibPluginClient.RCPC_clearMessages, false);
        document.getElementById("RCPC_getTotalUnreadCount").addEventListener('click', RongCloudLibPluginClient.RCPC_getTotalUnreadCount, false);
        document.getElementById("RCPC_getUnreadCount").addEventListener('click', RongCloudLibPluginClient.RCPC_getUnreadCount, false);
        document.getElementById("RCPC_getUnreadCountByConversationTypes").addEventListener('click', RongCloudLibPluginClient.RCPC_getUnreadCountByConversationTypes, false);
        document.getElementById("RCPC_setMessageReceivedStatus").addEventListener('click', RongCloudLibPluginClient.RCPC_setMessageReceivedStatus, false);
        document.getElementById("RCPC_clearMessagesUnreadStatus").addEventListener('click', RongCloudLibPluginClient.RCPC_clearMessagesUnreadStatus, false);
        document.getElementById("RCPC_setMessageExtra").addEventListener('click', RongCloudLibPluginClient.RCPC_setMessageExtra, false);
        document.getElementById("RCPC_getTextMessageDraft").addEventListener('click', RongCloudLibPluginClient.RCPC_getTextMessageDraft, false);
        document.getElementById("RCPC_saveTextMessageDraft").addEventListener('click', RongCloudLibPluginClient.RCPC_saveTextMessageDraft, false);
        document.getElementById("RCPC_clearTextMessageDraft").addEventListener('click', RongCloudLibPluginClient.RCPC_clearTextMessageDraft, false);
        document.getElementById("RCPC_createDiscussion").addEventListener('click', RongCloudLibPluginClient.RCPC_createDiscussion, false);
        document.getElementById("RCPC_getDiscussion").addEventListener('click', RongCloudLibPluginClient.RCPC_getDiscussion, false);
        document.getElementById("RCPC_setDiscussionName").addEventListener('click', RongCloudLibPluginClient.RCPC_setDiscussionName, false);
        document.getElementById("RCPC_addMemberToDiscussion").addEventListener('click', RongCloudLibPluginClient.RCPC_addMemberToDiscussion, false);
        document.getElementById("RCPC_removeMemberFromDiscussion").addEventListener('click', RongCloudLibPluginClient.RCPC_removeMemberFromDiscussion, false);
        document.getElementById("RCPC_quitDiscussion").addEventListener('click', RongCloudLibPluginClient.RCPC_quitDiscussion, false);
        document.getElementById("RCPC_setDiscussionInviteStatus").addEventListener('click', RongCloudLibPluginClient.RCPC_setDiscussionInviteStatus, false);
        document.getElementById("RCPC_syncGroup").addEventListener('click', RongCloudLibPluginClient.RCPC_syncGroup, false);
        document.getElementById("RCPC_joinGroup").addEventListener('click', RongCloudLibPluginClient.RCPC_joinGroup, false);
        document.getElementById("RCPC_quitGroup").addEventListener('click', RongCloudLibPluginClient.RCPC_quitGroup, false);
        document.getElementById("RCPC_joinChatRoom").addEventListener('click', RongCloudLibPluginClient.RCPC_joinChatRoom, false);
        document.getElementById("RCPC_quitChatRoom").addEventListener('click', RongCloudLibPluginClient.RCPC_quitChatRoom, false);
    },
    // deviceready Event Handler
    //
    // The scope of 'this' is the event. In order to call the 'receivedEvent'
    // function, we must explicitly call 'app.receivedEvent(...);'
    onDeviceReady: function() {
        
    }
};
app.initialize();



