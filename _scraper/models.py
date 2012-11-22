from django.db import models


class Article(models.Model):
    site = models.CharField(max_length=50)
    title = models.CharField(max_length=500)
    pub_date = models.DateTimeField(null=True)
