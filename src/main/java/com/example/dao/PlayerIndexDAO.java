package com.example.dao;

import com.example.model.PlayerIndex;
import com.mongodb.client.*;
import com.mongodb.client.model.Filters;
import com.mongodb.client.model.Updates;
import org.bson.Document;
import org.bson.types.ObjectId;

import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class PlayerIndexDAO {
    private static final Logger LOGGER = Logger.getLogger(PlayerIndexDAO.class.getName());
    private final MongoCollection<Document> col;
    private final IndexerDAO indexerDAO;

    public PlayerIndexDAO(MongoDatabase db, IndexerDAO indexerDAO) {
        this.col = db.getCollection("player_index");
        this.indexerDAO = indexerDAO;
        createIndexes();
    }

    private void createIndexes() {
        // Create indexes for better query performance
        try {
            col.createIndex(new Document("player_id", 1));
            col.createIndex(new Document("index_id", 1));
            col.createIndex(new Document("player_id", 1).append("index_id", 1));
            LOGGER.info("Indexes created successfully");
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Failed to create indexes", e);
        }
    }

    private static PlayerIndex toEntity(Document d) {
        if (d == null) return null;
        PlayerIndex pi = new PlayerIndex(
                d.getObjectId("_id"),
                d.getObjectId("player_id"),
                d.getObjectId("index_id"),
                d.getDouble("value")
        );
        
        // Add additional fields if they exist
        if (d.containsKey("player_name")) {
            pi.setPlayerName(d.getString("player_name"));
        }
        if (d.containsKey("player_age")) {
            pi.setPlayerAge(d.getInteger("player_age"));
        }
        if (d.containsKey("index_name")) {
            pi.setIndexName(d.getString("index_name"));
        }
        
        return pi;
    }

    private static Document toDoc(PlayerIndex pi) {
        Document d = new Document("player_id", pi.getPlayerId())
                .append("index_id", pi.getIndexId())
                .append("value", pi.getValue());
        if (pi.getId() != null) d.put("_id", pi.getId());
        return d;
    }

    // ======= READ =======

    public List<PlayerIndex> listByPlayer(ObjectId playerId) {
        List<PlayerIndex> list = new ArrayList<>();
        try (MongoCursor<Document> cur = col.find(Filters.eq("player_id", playerId)).iterator()) {
            while (cur.hasNext()) list.add(toEntity(cur.next()));
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error retrieving player indexes for player: " + playerId, e);
        }
        return list;
    }

    public PlayerIndex findById(ObjectId id) {
        try {
            return toEntity(col.find(Filters.eq("_id", id)).first());
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error finding player index by ID: " + id, e);
            return null;
        }
    }

    // ======= CREATE / UPDATE with VALIDATE =======

    /** insert mới nếu id == null; ngược lại update */
    public ObjectId upsert(PlayerIndex pi) {
        try {
            if (!indexerDAO.isWithinRange(pi.getIndexId(), pi.getValue()))
                throw new IllegalArgumentException("Giá trị " + pi.getValue() + " ngoài khoảng cho indexer này");

            if (pi.getId() == null) {
                Document d = toDoc(pi);
                col.insertOne(d);
                return d.getObjectId("_id");
            } else {
                col.updateOne(Filters.eq("_id", pi.getId()),
                        Updates.combine(
                            Updates.set("player_id", pi.getPlayerId()),
                            Updates.set("index_id", pi.getIndexId()),
                            Updates.set("value", pi.getValue())
                        ));
                return pi.getId();
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error upserting player index", e);
            throw new RuntimeException("Failed to save player index: " + e.getMessage(), e);
        }
    }

    // ======= DELETE =======

    public boolean deleteById(ObjectId id) {
        try {
            return col.deleteOne(Filters.eq("_id", id)).getDeletedCount() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error deleting player index: " + id, e);
            return false;
        }
    }

    public long deleteAllOfPlayer(ObjectId playerId) {
        try {
            return col.deleteMany(Filters.eq("player_id", playerId)).getDeletedCount();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error deleting all indexes for player: " + playerId, e);
            return 0;
        }
    }
    
    // === JOIN player_index + player + indexer để in bảng phẳng
    public List<Document> listAllJoined() {
        List<Document> out = new ArrayList<>();
        try {
            List<Document> pipeline = List.of(
                    new Document("$lookup",
                            new Document("from", "player")
                                    .append("localField", "player_id")
                                    .append("foreignField", "_id")
                                    .append("as", "player")),
                    new Document("$unwind", "$player"),
                    new Document("$lookup",
                            new Document("from", "indexer")
                                    .append("localField", "index_id")
                                    .append("foreignField", "_id")
                                    .append("as", "indexer")),
                    new Document("$unwind", "$indexer"),
                    new Document("$project",
                            new Document("_id", 1) // _id của player_index
                                    .append("player_id", "$player._id")
                                    .append("player_name", "$player.name")
                                    .append("player_age", "$player.age")
                                    .append("index_name", "$indexer.name")
                                    .append("value", "$value")),
                    new Document("$sort",
                            new Document("player_name", 1).append("index_name", 1))
            );
            
            try (MongoCursor<Document> cur = col.aggregate(pipeline).iterator()) {
                while (cur.hasNext()) out.add(cur.next());
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error retrieving joined player index data", e);
        }
        return out;
    }
    
    // Additional method to get player indexes with pagination
    public List<Document> listAllJoined(int page, int pageSize) {
        List<Document> out = new ArrayList<>();
        try {
            List<Document> pipeline = List.of(
                    new Document("$lookup",
                            new Document("from", "player")
                                    .append("localField", "player_id")
                                    .append("foreignField", "_id")
                                    .append("as", "player")),
                    new Document("$unwind", "$player"),
                    new Document("$lookup",
                            new Document("from", "indexer")
                                    .append("localField", "index_id")
                                    .append("foreignField", "_id")
                                    .append("as", "indexer")),
                    new Document("$unwind", "$indexer"),
                    new Document("$project",
                            new Document("_id", 1)
                                    .append("player_id", "$player._id")
                                    .append("player_name", "$player.name")
                                    .append("player_age", "$player.age")
                                    .append("index_name", "$indexer.name")
                                    .append("value", "$value")),
                    new Document("$sort",
                            new Document("player_name", 1).append("index_name", 1)),
                    new Document("$skip", (page - 1) * pageSize),
                    new Document("$limit", pageSize)
            );
            
            try (MongoCursor<Document> cur = col.aggregate(pipeline).iterator()) {
                while (cur.hasNext()) out.add(cur.next());
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error retrieving paginated player index data", e);
        }
        return out;
    }
    
    // Get total count for pagination
    public long getTotalCount() {
        try {
            return col.countDocuments();
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error counting player indexes", e);
            return 0;
        }
    }
}