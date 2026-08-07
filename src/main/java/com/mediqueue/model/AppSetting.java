package com.mediqueue.model;

import java.sql.Timestamp;

/**
 * AppSetting - persisted admin-editable business configuration.
 */
public class AppSetting {

    private String key;
    private String value;
    private String label;
    private String description;
    private Timestamp updatedAt;

    public String getKey() { return key; }
    public void setKey(String key) { this.key = key; }

    public String getValue() { return value; }
    public void setValue(String value) { this.value = value; }

    public String getLabel() { return label; }
    public void setLabel(String label) { this.label = label; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
}
