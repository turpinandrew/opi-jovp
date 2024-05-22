package org.lei.opi.jovp;

import java.lang.reflect.Type;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonSerializer;
import com.google.gson.JsonSerializationContext;

public class QuerySerializer implements JsonSerializer<Query> {
    public QuerySerializer() {
        super();
    }

    @Override
    public JsonElement serialize(final Query q, final Type type, final JsonSerializationContext context) {
        final JsonObject jsonObject = new JsonObject();

        jsonObject.add("distance", context.serialize(q.distance()));
        jsonObject.add("fov", context.serialize(q.fov()));
        jsonObject.add("viewMode", context.serialize(q.viewMode()));
        jsonObject.add("input", context.serialize(q.input()));
        jsonObject.add("pseudoGray", context.serialize(q.pseudoGray()));
        jsonObject.add("fullScreen", context.serialize(q.fullScreen()));
        jsonObject.add("tracking", context.serialize(q.tracking()));
        jsonObject.add("maxLum", context.serialize(q.maxLum()));
        jsonObject.add("maxPixel", context.serialize(q.maxPixel()));
        jsonObject.add("lumPrecision", context.serialize(q.lumPrecision()));
        jsonObject.add("gammaFile", context.serialize(q.invGammaFile()));
        jsonObject.add("monitor", context.serialize(q.monitor()));

        return jsonObject;
    }
}