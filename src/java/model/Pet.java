package model;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * Domain model representing a Pet, mapped to the Pets table.
 */
public class Pet {

    private int petId;
    private Customer owner;
    private String name;
    private String species;
    private String breed;
    private String gender;
    private LocalDate birthDate;
    private Double weight;
    private String photoUrl;
    private LocalDateTime createdAt;
    private String PhotoURL; 

    public Pet() {
    }

    public int getPetId() {
        return petId;
    }

    public void setPetId(int petId) {
        this.petId = petId;
    }

    public Customer getOwner() {
        return owner;
    }

    public void setOwner(Customer owner) {
        this.owner = owner;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getSpecies() {
        return species;
    }

    public void setSpecies(String species) {
        this.species = species;
    }

    public String getBreed() {
        return breed;
    }

    public void setBreed(String breed) {
        this.breed = breed;
    }

    public String getGender() {
        return gender;
    }

    public void setGender(String gender) {
        this.gender = gender;
    }

    public LocalDate getBirthDate() {
        return birthDate;
    }

    public void setBirthDate(LocalDate birthDate) {
        this.birthDate = birthDate;
    }

    public Double getWeight() {
        return weight;
    }

    public void setWeight(Double weight) {
        this.weight = weight;
    }

    public String getPhotoUrl() {
        String raw = (photoUrl != null && !photoUrl.isBlank()) ? photoUrl : PhotoURL;
        return normalizePhotoPath(raw);
    }

    public void setPhotoUrl(String photoUrl) {
        this.photoUrl = photoUrl;
        if (photoUrl != null && !photoUrl.isBlank()) {
            this.PhotoURL = photoUrl;
        }
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public String getPhotoURL() {
        String raw = (PhotoURL != null && !PhotoURL.isBlank()) ? PhotoURL : photoUrl;
        return normalizePhotoPath(raw);
    }

    public void setPhotoURL(String PhotoURL) {
        this.PhotoURL = PhotoURL;
        if (PhotoURL != null && !PhotoURL.isBlank()) {
            this.photoUrl = PhotoURL;
        }
    }

    private String normalizePhotoPath(String raw) {
        if (raw == null) {
            return null;
        }
        String trimmed = raw.trim();
        if (trimmed.isEmpty()) {
            return null;
        }
        if (trimmed.startsWith("http://") || trimmed.startsWith("https://") || trimmed.startsWith("/")) {
            return trimmed;
        }
        return "/" + trimmed;
    }
    
    
}

